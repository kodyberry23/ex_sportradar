defmodule Sportradar.PushFeedManager do
  use GenServer

  def start_link(_init) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  ##### Client Functions #####
  @impl true
  def init(_init) do
    {:ok, %{}}
  end
end
