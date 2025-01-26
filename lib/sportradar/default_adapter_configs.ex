defmodule Sportradar.DefaultAdapterConfigs do
  @behaviour Sportradar.AdapterConfig

  @impl true
  def get_config(:default, Tesla.Adapter.Hackney), do: []

  @impl true
  def get_config(:stream, Tesla.Adapter.Hackney) do
    [
      recv_timeout: :infinity,
      async: true,
      follow_redirect: true
    ]
  end

  @impl true
  def get_config(:default, Tesla.Adapter.Mint), do: []

  @impl true
  def get_config(:stream, Tesla.Adapter.Mint) do
    [
      timeout: :infinity,
      body_as: :stream
    ]
  end

  @impl true
  def get_config(:default, Tesla.Adapter.Finch), do: [name: SportsradarFinch]

  @impl true
  def get_config(:stream, Tesla.Adapter.Finch), do: [name: SportsradarFinch]

  @impl true
  def get_config(type, adapter) do
    {:error, Sportradar.Error.new("Adapter #{inspect(adapter)} does not support #{type} mode")}
  end
end
