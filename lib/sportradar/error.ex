defmodule Sportradar.Error do
  @type t :: %__MODULE__{
          message: String.t(),
          status: integer() | nil,
          description: String.t()
        }

  defexception [:message, :status, :description]

  def from_response(%Tesla.Env{} = response) do
    %__MODULE__{
      status: response.status,
      message: response.body["message"],
      description: response.body["description"]
    }
  end

  def new(message) when is_binary(message) do
    %__MODULE__{message: message}
  end
end

defmodule Sportradar.InvalidAuthError do
  defexception message: """
               Sportradar API key not configured.

               Please configure your API key in config.exs:

               config :sportradar,
                 api_key: System.get_env("SPORTRADAR_API_KEY")
               """
end
