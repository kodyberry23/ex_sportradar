defmodule Sportradar.Utils.SimulationUtils do
  alias Sportradar.Client
  @playback_url "https://playback.sportradar.com/graphql"

  @recordings_query """
  query getRecordings($league: String) {
    recordings(league: $league) {
      id
      scheduled
      meta
      league
      start
      end
      title
      apis {
        name
        description
        formats
      }
    }
  }
  """

  @create_session_mutation """
  mutation CreateSession($input: CreateSessionInput!) {
    createSession(input: $input)
  }
  """

  @doc """
  Fetches available recordings for a given league.

  ## Examples

      iex> SimulationUtil.fetch_recordings("nfl")
      {:ok, [%{id: "95aa13a0-...", league: "nfl", ...}]}

  """
  def fetch_recordings(league) do
    result =
      Client.post(@playback_url,
        body: %{
          query: @recordings_query,
          variables: %{league: league}
        }
      )

    case result do
      {:ok, %{"data" => %{"recordings" => recordings}}} ->
        {:ok, recordings}

      {:ok, %{"errors" => errors}} ->
        {:error, format_graphql_errors(errors)}

      error ->
        error
    end
  end

  @doc """
  Creates a session for a given recording ID.

  ## Examples

      iex> SimulationUtil.create_session("95aa13a0-6538-11ef-9287-d597687b4672")
      {:ok, "60414140-53c7-11ed-bd68-ad2289887b03_-5507944226"}

  """
  def create_session(recording_id) do
    result =
      Client.post(@playback_url,
        body: %{
          query: @create_session_mutation,
          variables: %{input: %{recordingId: recording_id}}
        }
      )

    case result do
      {:ok, %{"data" => %{"createSession" => session_id}}} ->
        {:ok, session_id}

      {:ok, %{"errors" => errors}} ->
        {:error, format_graphql_errors(errors)}

      error ->
        error
    end
  end

  @doc """
  Constructs a playback URL for a specific recording.

  ## Examples

      iex> SimulationUtil.build_playback_url("nfl", "recording123", "json_feed", "json", "session456")
      "https://playback.sportradar.com/replay/nfl/recording123?feed=json_feed&contentType=json&sessionId=session456"

  """
  def build_playback_url(league, recording_id, feed, content_type, session_id) do
    "https://playback.sportradar.com/replay/#{league}/#{recording_id}?feed=#{feed}&contentType=#{content_type}&sessionId=#{session_id}"
  end

  @doc """
  Constructs a push subscription URL for a specific recording.

  ## Examples

      iex> SimulationUtil.build_subscribe_url("events", "recording123")
      "https://playback.sportradar.com/subscribe/events?recording_id=recording123"

  """
  def build_subscribe_url(recording_id, feed_name \\ "events") do
    url = "https://playback.sportradar.com/subscribe/#{feed_name}?recording_id=#{recording_id}"

    {:ok, url}
  end

  # Private Functions

  defp format_graphql_errors(errors) when is_list(errors) do
    errors
    |> Enum.map(& &1["message"])
    |> Enum.join(", ")
  end

  defp format_graphql_errors(error), do: "Unknown error: #{inspect(error)}"
end
