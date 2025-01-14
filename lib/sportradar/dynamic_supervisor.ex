defmodule Sportradar.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def subscribe_to_match_feed(match_id) do
    DynamicSupervisor.start_child(__MODULE__, {Sportradar.EventHandler, match_id})
  end
end
