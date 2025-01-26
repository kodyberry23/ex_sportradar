defmodule Sportradar do
  @moduledoc """
  Main interface for the Sportradar streaming API.
  Provides functions for subscribing to match feeds and managing event streams.
  """

  require Logger
  alias Phoenix.PubSub
  alias Sportradar.Client
  alias Sportradar.EventManager

  @match_supervisor Sportradar.MatchSupervisor
  @registry_module Sportradar.MatchRegistry

  @doc """
  Lists all active event managers for a match.
  """
  def list_match_managers(match_id) do
    Registry.lookup(@registry_module, match_id)
  end

  @doc """
  Subscribes to a match feed using default settings.
  """
  def subscribe_to_match_feed(match_id) when is_binary(match_id) do
    subscribe_to_match_feed(Client.new(:stream, %{}), match_id, [])
  end

  @doc """
  Subscribes to a match feed with custom options.
  """
  def subscribe_to_match_feed(match_id, request_opts)
      when is_binary(match_id) and is_list(request_opts) do
    subscribe_to_match_feed(Client.new(:stream, %{}), match_id, request_opts)
  end

  @doc """
  Subscribes to a match feed with a custom client and options.
  """
  def subscribe_to_match_feed(%Tesla.Client{} = client, match_id, request_opts)
      when is_binary(match_id) and is_list(request_opts) do
    init = build_init_state(client, match_id, request_opts)
    start_and_subscribe(init)
  end

  ##############################################
  # Private Functions
  ##############################################
  defp build_init_state(client, match_id, request_opts) do
    %{
      match_id: match_id,
      buffer: "",
      channel: "match:#{match_id}",
      heartbeat: system_time(),
      last_event_state: %{},
      retry_count: 0,
      client: client,
      request_opts: request_opts
    }
  end

  defp start_and_subscribe(init) do
    with {:ok, _} <- DynamicSupervisor.start_child(@match_supervisor, {EventManager, init}),
         {:ok, _} = result <-
           EventManager.subscribe(init.client, init.match_id, init.request_opts),
         :ok <- PubSub.subscribe(Sportradar.PubSub, init.channel) do
      result
    else
      error ->
        cleanup_subscription(init.match_id)
        error
    end
  end

  defp cleanup_subscription(match_id) do
    {pid, _} =
      match_id
      |> list_match_managers()
      |> List.last()

    case DynamicSupervisor.terminate_child(@match_supervisor, pid) do
      :ok = result ->
        Logger.debug("Cleaned up EventManager process for match_id: #{match_id}")
        result

      error ->
        Logger.debug(
          "Error: Failed to cleanup EventManager, process :not_found for match_id: #{match_id}"
        )

        error
    end
  end

  defp system_time, do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
