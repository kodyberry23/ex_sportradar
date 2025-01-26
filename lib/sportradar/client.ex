defmodule Sportradar.Client do
  import Ecto.Changeset

  alias Sportradar.DefaultAdapterConfigs
  alias Sportradar.Error, as: SportradarError

  @type request_opts :: [
          method: :get | :post,
          query: keyword(),
          body: map() | nil,
          opts: keyword(),
          schema: module() | nil
        ]

  def handle_response({:ok, %Tesla.Env{status: 200, body: body} = response})
      when is_reference(body),
      do: {:ok, response}

  def handle_response({:ok, %Tesla.Env{status: 200, body: body, opts: [schema: nil]}}),
    do: {:ok, body}

  def handle_response({:ok, %Tesla.Env{status: 200, body: body, opts: [schema: schema]}}) do
    changeset = apply(schema, :changeset, [struct(schema), body])

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  def handle_response({:ok, %Tesla.Env{status: status} = response}) when status in 400..599 do
    {:error, SportradarError.from_response(response)}
  end

  def handle_response({:error, reason}) do
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
      {Tesla.Middleware.BaseUrl, opts[:baseurl] || get_base_url()},
      {Tesla.Middleware.Headers, build_headers(type, opts[:headers])},
      Sportradar.Middleware.AuthMiddleware
    ]

    adapter = opts[:adapter] || get_adapter()
    http_opts = adapter_config_module().get_config(type, adapter)

    Tesla.client(middleware, {adapter, http_opts})
  end

  def new(_type, _opts),
    do: raise(Sportradar.InvalidClientTypeError)

  @spec request(Tesla.Client.t(), String.t(), request_opts()) ::
          {:ok, struct() | map()} | {:error, SportradarError.t() | Ecto.Changeset.t()}
  def request(client, url, opts \\ []) do
    request_opts = Keyword.get(opts, :opts, [])
    schema = Keyword.get(opts, :schema)

    params = [
      method: Keyword.get(opts, :method, :get),
      url: url,
      query: Keyword.get(opts, :query, []),
      body: Keyword.get(opts, :body, %{}),
      opts: Keyword.put_new(request_opts, :schema, schema)
    ]

    client
    |> Tesla.request(params)
    |> handle_response()
  end

  ####### Request Convenience Functions #######
  def get(%Tesla.Client{} = client, url), do: get(client, url, [])
  def get(url, opts), do: request(new(), url, Keyword.put(opts, :method, :get))
  def get(client, url, opts), do: request(client, url, Keyword.put(opts, :method, :get))

  def post(%Tesla.Client{} = client, url), do: post(client, url, [])
  def post(url, opts), do: request(new(), url, Keyword.put(opts, :method, :post))
  def post(client, url, opts), do: request(client, url, Keyword.put(opts, :method, :post))

  def subscribe(url, opts), do: subscribe(new(:stream), url, opts)

  def subscribe(%Tesla.Client{adapter: {adapter, _, _}} = client, url, opts) do
    match_id = get_in(opts, [:opts, :match_id])

    with :ok <- verify_adapter_streaming(adapter, opts),
         {:ok, _} <- verify_event_handler_started(match_id),
         :ok <- verify_match_id(match_id),
         {:ok, response} <- request(client, url, opts) do
      {:ok, response}
    end
  end

  ####### Private Functions #######
  defp adapter_config_module() do
    Application.get_env(:ex_sportradar, :adapter_config_module, DefaultAdapterConfigs)
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
    Application.get_env(:ex_sportradar, :adapter, Tesla.Adapter.Hackney)
  end

  defp get_base_url() do
    Application.get_env(:ex_sportradar, :base_url, "https://api.sportradar.com")
  end

  defp verify_adapter_streaming(Tesla.Adapter.Finch, opts) do
    case Keyword.get(opts, :response) do
      :stream ->
        :ok

      _ ->
        {:error,
         SportradarError.new(
           "Error: To enable response streaming with the Tesla.Adapter.Finch adapter, you must pass the following request options: [opts: [response: :stream]]"
         )}
    end
  end

  defp verify_adapter_streaming(_adapter, _opts), do: :ok

  defp verify_event_handler_started(match_id) do
    case Registry.lookup(Sportradar.MatchRegistry, match_id) do
      [] ->
        {:error,
         SportradarError.new(
           "Please be sure to add Sportradar.EventSupervisor to your applications supervision tree in order to use the subscribe/3 function"
         )}

      _managers ->
        {:ok, match_id}
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
