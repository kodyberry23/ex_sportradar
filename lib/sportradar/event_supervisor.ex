defmodule Sportradar.EventSupervisor do
  @moduledoc """
  Top-level supervisor for the Sportradar event system. It supervises:
  - PubSub system for event broadcasting
  - Registry for tracking EventManager processes
  - DynamicSupervisor for managing EventManager lifecycles
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Phoenix.PubSub, name: Sportradar.PubSub},
      {Registry, keys: :duplicate, name: Sportradar.MatchRegistry},
      # Configure the DynamicSupervisor directly here
      {DynamicSupervisor,
       strategy: :one_for_one, name: Sportradar.MatchSupervisor, max_restarts: 3, max_seconds: 60}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
