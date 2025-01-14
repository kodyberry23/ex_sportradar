defmodule Sportradar.EventSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    base_children = [
      {Registry, name: Sportradar.MatchRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Sportradar.DynamicSupervisor}
    ]

    children =
      case Code.ensure_loaded?(Phoenix.PubSub) do
        true ->
          [{Phoenix.PubSub, name: Sportradar.PubSub} | base_children]

        false ->
          base_children
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
