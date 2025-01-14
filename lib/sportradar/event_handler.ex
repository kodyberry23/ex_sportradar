defmodule Sportradar.EventHandler do
  use GenServer

  alias Sportradar.Client
  alias Sportradar.DynamicSupervisor
  alias Sportradar.Utils.SimulationUtils

  #### Client #####
  def start_link(init) do
    GenServer.start_link(__MODULE__, init, via_tuple(init.match_id))
  end

  #### Server Callbacks #####
  @impl true
  def init(match_id) do
    with {:ok, url} <- SimulationUtils.build_subscribe_url(match_id),
         {:sportradar_event, _} <- Client.subscribe(url, %{method: :get}) do
      initial_heartbeat =
        :millisecond
        |> DateTime.utc_now()
        |> DateTime.to_unix()

      init_state = %{
        match_id: match_id,
        heartbeat: initial_heartbeat,
        game_data: %{}
      }

      schedule_connection_check(initial_heartbeat)
      {:ok, init_state}
    end
  end

  @impl true
  def handle_info({:check_connection, heartbeat}, state) do
    if heartbeat < state.hearbeat do
      {:noreply, state}
    else
    end
  end

  @impl true
  def handle_info({:sportradar_event, response}, state) do
    {:noreply, %{state | game_data: response}}
  end

  @impl true
  def terminate(reason, state) do
  end

  #### Private Functions ####
  defp schedule_connection_check(heartbeat) do
    Process.send_after(self(), {:check_connection, heartbeat}, 15_000)
  end

  defp verify_last_heartbeat() do
  end

  defp via_tuple(match_id) do
    {:via, Registry, {Sportradar.MatchRegistry, match_id}}
  end
end
