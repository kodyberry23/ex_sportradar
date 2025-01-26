defmodule Sportradar.Middleware.AuthMiddleware do
  @behaviour Tesla.Middleware

  def call(env, next, _) do
    env
    |> add_auth()
    |> Tesla.run(next)
  end

  defp add_auth(env) do
    cond do
      simulation_endpoint?(env) -> env
      insights_endpoint?(env) -> add_auth_header(env)
      true -> add_auth_query(env)
    end
  end

  defp simulation_endpoint?(env) do
    String.contains?(env.url, "playback")
  end

  defp insights_endpoint?(env) do
    String.contains?(env.url, "insights")
  end

  defp add_auth_header(env) do
    Tesla.put_header(env, "Authorization", get_api_key())
  end

  defp add_auth_query(env) do
    Map.update!(env, :query, &(&1 ++ [api_key: get_api_key()]))
  end

  defp get_api_key do
    Application.get_env(:ex_sportradar, :api_key) ||
      raise """
      Sportradar API key not configured.

      Please configure your API key in config.exs:

      config :ex_sportradar,
        api_key: System.get_env("SPORTRADAR_API_KEY")
      """
  end
end
