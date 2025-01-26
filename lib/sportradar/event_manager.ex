defmodule Sportradar.EventManager do
  use GenServer

  require Logger

  alias Phoenix.PubSub
  alias Sportradar.Client
  alias Sportradar.Utils.SimulationUtils

  @registry_module Sportradar.MatchRegistry
  @pubsub_module Sportradar.PubSub

  ##############################################
  # Client
  ##############################################
  def start_link(init) do
    GenServer.start_link(__MODULE__, init)
  end

  def get_current_state(match_id) do
    [{pid, _}] = Registry.lookup(@registry_module, match_id)
    GenServer.call(pid, :get_current_state)
  end

  def subscribe(client, match_id, request_opts) do
    case Registry.lookup(@registry_module, match_id) do
      [] ->
        {:error,
         Sportradar.Error.new(
           "EventManager for match_id: #{match_id} not found. Please ensure your EventManager process has been started"
         )}

      managers ->
        managers
        |> List.last()
        |> elem(0)
        |> GenServer.call({:subscribe, client, match_id, request_opts}, :infinity)
    end
  end

  ##############################################
  # Server Callbacks
  ##############################################
  @impl true
  def init(init) do
    Registry.register(@registry_module, init.match_id, [])

    {:ok, init}
  end

  @impl true
  def handle_call(:get_current_state, _, state), do: {:reply, {:ok, state}, state}

  @impl true
  def handle_call({:subscribe, client, match_id, request_opts}, _from, state) do
    updated_opts =
      request_opts
      |> Keyword.get(:opts, [])
      |> Keyword.put_new(:match_id, match_id)

    with updated_request_opts <-
           request_opts
           |> Keyword.put(:opts, updated_opts)
           |> Keyword.merge([method: :get, body: nil], fn _k, v1, _v2 -> v1 end),
         {:ok, url} <- SimulationUtils.build_subscribe_url(match_id),
         {:ok, _} = result <- Client.subscribe(client, url, updated_request_opts) do
      schedule_health_check(state.heartbeat)
      {:reply, result, state}
    else
      error ->
        {:stop, :CONNECTION_FAILED, error, state}
    end
  end

  @impl true
  def handle_call(:initiate_new_connection, _from, old_state) do
    Logger.info(
      "Initiating restart for match #{old_state.match_id}, retry count: #{old_state.retry_count}"
    )

    with {:ok, new_event_manager} <-
           DynamicSupervisor.start_child(
             Sportradar.MatchSupervisor,
             {__MODULE__, %{old_state | buffer: "", retry_count: 0, heartbeat: system_time()}}
           ),
         {:ok, _} <-
           GenServer.call(
             new_event_manager,
             {:subscribe, old_state.client, old_state.match_id, old_state.request_opts}
           ) do
      {:ok, new_event_manager}
    end
  end

  @impl true
  def handle_info(
        {:check_connection, last_heartbeat_time},
        %{heartbeat: current_heartbeat_time} = state
      ) do
    if last_heartbeat_time < current_heartbeat_time do
      schedule_health_check(current_heartbeat_time)
      {:noreply, state}
    else
      maybe_restart_connection(state)
    end
  end

  ##############################################
  # Finch response handler callbacks
  ##############################################
  def handle_info({_ref, {:status, status, headers}}, state) do
    Logger.debug("Received status #{status} with headers #{inspect(headers)}")
    {:noreply, state}
  end

  def handle_info({_ref, {:data, chunk}}, state) when is_binary(chunk) do
    handle_chunk(chunk, state)
  end

  def handle_info({_ref, :eof}, state) do
    Logger.info("Stream ended")
    {:noreply, state}
  end

  def handle_info({_ref, {:error, error}}, state) do
    Logger.error("Stream error: #{inspect(error)}")
    {:stop, {:stream_error, error}, state}
  end

  ##############################################
  # Hackney response handler callbacks
  ##############################################
  @impl true
  def handle_info({:hackney_response, _ref, chunk}, state) when is_binary(chunk) do
    handle_chunk(chunk, state)
  end

  @impl true
  def handle_info({:hackney_response, _ref, _}, state), do: {:noreply, state}

  ##############################################
  # Mint response handler callbacks
  ##############################################
  @impl true
  def handle_info({:mint, _conn, _ref, {:data, chunk}}, state) when is_binary(chunk) do
    handle_chunk(chunk, state)
  end

  def handle_info({:mint, _conn, _ref, _}, state), do: {:noreply, state}

  ##############################################
  # Unhandled response handler callbacks
  ##############################################
  @impl true
  def handle_info(event, state) do
    Logger.info("Unhandled event: #{inspect(event)}")
    {:noreply, state}
  end

  ##############################################
  # Terminate callbacks
  ##############################################
  @impl true
  def terminate(:normal, _state) do
    :ok
  end

  def terminate({:restart_failed, reason}, state) do
    Logger.error("Restart failed for match #{state.match_id}: #{inspect(reason)}")
  end

  def terminate(_reason, state) do
    Registry.unregister(Sportradar.MatchRegistry, state.match_id)
  end

  ##############################################
  # Private Functions
  ##############################################
  def max_retries(), do: Application.get_env(:ex_sportradar, :max_retries, 3)
  def restart_timeout(), do: Application.get_env(:ex_sportradar, :restart_timeout, 5_000)

  def health_check_interval() do
    health_check_interval = Application.get_env(:ex_sportradar, :health_check_interval, 15_000)

    if health_check_interval <= 5000 do
      raise Sportradar.InvalidConfigError,
        message: """
        health_check_interval must be greater than 5 seconds.

        Please adjust your config accordingly.

        config :ex_sportradar,
          health_check_interval: 10_000

        Sportradar sends a heartbeat every 5 seconds. Setting the health check to 5 seconds
        or less will cause the health check to fail as the heartbeat would not be updated soon enough.
        """
    else
      health_check_interval
    end
  end

  defp maybe_restart_connection(state) do
    if state.retry_count < max_retries() do
      case GenServer.call(self(), {:initiate_new_connection, state}, restart_timeout()) do
        {:ok, _} -> {:stop, :normal, state}
        _ -> {:noreply, %{state | retry_count: state.retry_count + 1}}
      end
    else
      {:stop, :MAX_RETRIES_EXCEEDED, state}
    end
  end

  defp handle_chunk(chunk, state) do
    combined_data = (state.buffer || "") <> chunk

    case process_buffered_data(combined_data) do
      {:complete, json_objects, remainder} ->
        {final_state, _} =
          Enum.reduce(json_objects, {state, []}, fn json_str, {current_state, _} ->
            case process_json_object(json_str, current_state) do
              {:noreply, new_state} -> {new_state, []}
              other -> {current_state, [other]}
            end
          end)

        {:noreply, %{final_state | buffer: remainder}}

      {:incomplete, data} ->
        {:noreply, %{state | buffer: data}}
    end
  end

  defp process_buffered_data(data) do
    case String.split(data, "\n", trim: false) do
      [] ->
        {:incomplete, data}

      parts ->
        {complete_parts, [last_part]} = Enum.split(parts, -1)

        json_objects = Enum.filter(complete_parts, &(String.trim(&1) != ""))

        if length(json_objects) > 0 do
          {:complete, json_objects, last_part}
        else
          {:incomplete, data}
        end
    end
  end

  defp process_json_object(json_string, state) do
    case Jason.decode(json_string) do
      {:ok, %{"heartbeat" => data}} ->
        handle_heartbeat(data, state)

      {:ok, %{"payload" => _data, "metadata" => %{"league" => league}} = event} ->
        handle_event(event, league, state)

      {:error, reason} ->
        Logger.error("Failed to decode JSON: #{inspect(reason)}, string: #{inspect(json_string)}")
        {:noreply, state}
    end
  end

  defp schedule_health_check(heartbeat) do
    Process.send_after(
      self(),
      {:check_connection, heartbeat},
      health_check_interval()
    )
  end

  defp handle_heartbeat(_data, state) do
    heartbeat = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    {:noreply, %{state | heartbeat: heartbeat}}
  end

  defp handle_event(event_data, league, state) do
    case build_event_struct(league, event_data) do
      {:ok, event_struct} ->
        broadcast_event(event_struct, state)
        {:noreply, %{state | last_event_state: event_struct}}

      {:error, reason} ->
        Logger.error("Failed to build event struct: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp build_event_struct("nfl", data) do
    changeset =
      apply(Sportradar.Sports.Football.Nfl.PushEvent, :changeset, [
        struct(Sportradar.Sports.Football.Nfl.PushEvent),
        data
      ])

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  defp build_event_struct(league, _data) do
    {:error, "Unsupported league: #{league}"}
  end

  defp broadcast_event(event, state) do
    IO.inspect({:ex_sportradar_event, event})
    PubSub.broadcast(
      @pubsub_module,
      state.channel,
      {:ex_sportradar_event, event}
    )
  end

  defp system_time(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
