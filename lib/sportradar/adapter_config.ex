defmodule Sportradar.AdapterConfig do
  @type type :: :default | :stream
  @type adapter :: module()

  @callback get_config(type(), adapter()) :: keyword()
end
