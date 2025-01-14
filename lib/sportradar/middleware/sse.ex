defmodule Sportradar.Middleware.SSE do
  @behaviour Tesla.Middleware

  @default_content_types ["text/event-stream"]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    with {:ok, env} <- Tesla.run(env, next) do
      decode(env, opts)
    end
  end

  def decode(env, _opts) do
    if decodable_content_type?(env) do
      {:ok, %{env | body: decode_body(env.body)}}
    else
      {:ok, env}
    end
  end

  defp decode_body(body) when is_struct(body, Stream) or is_function(body) do
    body
    |> Stream.chunk_while(
      "",
      fn elem, acc ->
        {chunks, [rest]} = (acc <> elem) |> String.split("\n\n") |> Enum.split(-1)
        {:cont, chunks, rest}
      end,
      fn
        "" -> {:cont, ""}
        acc -> {:cont, acc, ""}
      end
    )
    |> Stream.flat_map(& &1)
    |> Stream.map(&decode_chunk/1)
    |> Stream.reject(&is_nil/1)
  end

  defp decode_body(binary) when is_binary(binary) do
    binary
    |> String.split("\n\n")
    |> Enum.map(&decode_chunk/1)
    |> Enum.reject(&is_nil/1)
  end

  defp decode_chunk(chunk) do
    case Jason.decode(chunk) do
      {:ok, %{"heartbeat" => msg}} -> msg
      {:ok, %{"payload" => msg}} -> msg
      _ -> nil
    end
  end

  defp decodable_content_type?(env) do
    case Tesla.get_header(env, "content-type") do
      nil ->
        false

      content_type ->
        Enum.any?(@default_content_types, &String.starts_with?(content_type, &1))
    end
  end
end
