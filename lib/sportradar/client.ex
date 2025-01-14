defmodule Sportradar.Client do
  import Ecto.Changeset

  alias Sportradar.Error, as: SportradarError

  @type request_opts :: [
          method: :get | :post,
          query: keyword(),
          body: map(),
          opts: keyword(),
          schema: module() | nil
        ]

  def handle_response({:ok, response}, schema), do: handle_response(response, schema)

  def handle_response(%Tesla.Env{status: 200, body: body}, nil), do: {:ok, body}

  def handle_response(%Tesla.Env{status: 200, body: body}, module) do
    changeset = apply(module, :changeset, [struct(module), body])

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  def handle_response(%Tesla.Env{status: status} = response, _) when status in 400..599 do
    {:error, SportradarError.from_response(response)}
  end

  def handle_response({:error, reason}, _) do
    {:error, SportradarError.new("Request failed: #{inspect(reason)}")}
  end

  def new(type \\ :default, opts \\ %{})

  def new(:default = type, opts) do
    middleware = [
      {Tesla.Middleware.BaseUrl, opts[:baseurl] || get_base_url()},
      {Tesla.Middleware.Headers, build_headers(type, opts[:headers])},
      Sportradar.Middleware.AuthMiddleware,
      Tesla.Middleware.JSON
    ]

    adapter = opts[:adapter] || get_adapter()
    http_opts = adapter_config_module().get_config(type, adapter)

    Tesla.client(middleware, {adapter, http_opts})
  end

  def new(:stream = type, opts) do
    middleware = [
      Tesla.Middleware.SSE,
      {Tesla.Middleware.BaseUrl, opts[:baseurl] || get_base_url()},
      {Tesla.Middleware.Headers, build_headers(type, opts[:headers])},
      Sportradar.Middleware.AuthMiddleware
    ]

    adapter = opts[:adapter] || get_adapter()
    http_opts = adapter_config_module().get_config(type, adapter)

    Tesla.client(middleware, {adapter, http_opts})
  end

  def new(type, _opts),
    do: {:error, SportradarError.new("Error: Invalid client type provided: #{type}")}

  @spec request(Tesla.Client.t(), String.t(), request_opts()) ::
          {:ok, struct() | map()} | {:error, SportradarError.t() | Ecto.Changeset.t()}
  def request(client, url, opts \\ []) do
    request_opts = [
      method: Keyword.get(opts, :method, :get),
      url: url,
      query: Keyword.get(opts, :query, []),
      body: Keyword.get(opts, :body, %{}),
      opts: Keyword.get(opts, :opts, [])
    ]

    client
    |> Tesla.request(request_opts)
    |> handle_response(Keyword.get(opts, :schema))
  end

  ####### Request Convenience Functions #######
  def get(%Tesla.Client{} = client, url), do: get(client, url, [])
  def get(url, opts), do: request(new(), url, Keyword.put(opts, :method, :get))
  def get(client, url, opts), do: request(client, url, Keyword.put(opts, :method, :get))

  def post(%Tesla.Client{} = client, url), do: post(client, url, [])
  def post(url, opts), do: request(new(), url, Keyword.put(opts, :method, :post))
  def post(client, url, opts), do: request(client, url, Keyword.put(opts, :method, :post))

  def subscribe(url, opts), do: subscribe(new(:stream), url, opts)

  def subscribe(%Tesla.Client{} = client, url, opts) do
    with :ok <- verify_event_handler_started(),
         :ok <- verify_match_id(opts[:match_id]),
         {:ok, response} <- request(client, url, opts) do
      {:sportradar_event, response}
    end
  end

  ####### Private Functions #######
  defp adapter_config_module() do
    Application.get_env(:sportradar, :adapter_config_module, DefaultAdapterConfigs)
  end

  defp build_headers(:default, nil),
    do: [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

  defp build_headers(:stream, nil),
    do: [
      {"accept", "text/event-stream"},
      {"cache-control", "no-cache"},
      {"connection", "keep-alive"}
    ]

  defp get_adapter() do
    Application.get_env(:sportradar, :adapter, Tesla.Adapter.Hackney)
  end

  defp get_base_url() do
    Application.get_env(:sportradar, :base_url, "https://api.sportradar.com")
  end

  defp verify_event_handler_started() do
    case Process.whereis(Sportradar.EventHandler) do
      process when is_pid(process) ->
        :ok

      _ ->
        {:error,
         SportradarError.new(
           "Please be sure to add Sportradar.EventSupervisor to your applications supervison tree in order to use the subscribe/3 function"
         )}
    end
  end

  defp verify_match_id(match_id) when is_binary(match_id), do: :ok

  defp verify_match_id(_),
    do:
      {:error,
       SportradarError.new(
         "Error: Match ID is required when calling subscription. Please add %{match_id: <your-match-id>} in the body of the request"
       )}
end
