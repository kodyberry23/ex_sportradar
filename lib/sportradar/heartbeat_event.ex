defmodule Sportradar.HeartbeatEvent do
  use Sportradar.Schema

  embedded_schema do
    field(:interval, :integer)
  end

  def changeset(heartbeat, attrs) do
    fields = __schema__(:fields)

    heartbeat
    |> cast(attrs, fields)
    |> validate_required([:interval])
  end
end
