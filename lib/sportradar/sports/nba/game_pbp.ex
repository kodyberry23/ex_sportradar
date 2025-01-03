defmodule Sportradar.Sports.NBA.GamePBP do
  use Sportradar.Schema

  @embedded_fields [:time_zones, :home, :away, :broadcasts, :season, :periods, :events, :deleted_events]

  embedded_schema do
    field :status, Ecto.Enum, values: [:CLOSED, :IN_PROGRESS]
    field :coverage, :string
    field :scheduled, :string
    field :duration, :string
    field :attendance, :integer
    field :parent_id, :string
    field :lead_changes, :integer
    field :times_tied, :integer
    field :clock, :string
    field :quarter, :integer
    field :track_on_court, :boolean
    field :reference, :string
    field :entry_mode, :string
    field :sr_id, :string
    field :clock_decimal, :string
    field :venue, :string

    embeds_one :time_zones, TimeZones
    embeds_one :home, Team
    embeds_one :away, Team
    embeds_many :broadcasts, Broadcast
    embeds_one :season, Season
    embeds_many :periods, Period
    embeds_many :events, Event
    embeds_many :deleted_events, DeletedEvent
  end

  def changeset(game_pbp, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    game_pbp
    |> cast(attrs, fields)
    |> validate_required([:status, :scheduled, :clock, :quarter])
    |> cast_embed(:time_zones)
    |> cast_embed(:home, required: true)
    |> cast_embed(:away, required: true)
    |> cast_embed(:broadcasts)
    |> cast_embed(:season, required: true)
    |> cast_embed(:periods)
    |> cast_embed(:events)
    |> cast_embed(:deleted_events)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.TimeZones do
  use Sportradar.Schema

  embedded_schema do
    field :venue, :string
    field :home, :string
    field :away, :string
  end

  def changeset(time_zones, attrs) do
    fields = __schema__(:fields)

    time_zones
    |> cast(attrs, fields)
    |> validate_required([:venue, :home, :away])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Team do
  use Sportradar.Schema

  @embedded_fields [:record]

  embedded_schema do
    field :name, :string
    field :alias, :string
    field :market, :string
    field :id, :string
    field :points, :integer
    field :bonus, :boolean
    field :sr_id, :string
    field :remaining_timeouts, :integer
    field :reference, :string

    embeds_one :record, Record
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    team
    |> cast(attrs, fields)
    |> validate_required([:name, :id, :points])
    |> cast_embed(:record)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Broadcast do
  use Sportradar.Schema

  embedded_schema do
    field :network, :string
    field :type, Ecto.Enum, values: [:TV, :RADIO, :DIGITAL]
    field :locale, :string
    field :channel, :string
  end

  def changeset(broadcast, attrs) do
    fields = __schema__(:fields)

    broadcast
    |> cast(attrs, fields)
    |> validate_required([:network, :type])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Season do
  use Sportradar.Schema

  embedded_schema do
    field :id, :string
    field :year, :integer
    field :type, Ecto.Enum, values: [:REGULAR_SEASON, :PLAYOFFS, :PRESEASON]
    field :name, :string
  end

  def changeset(season, attrs) do
    fields = __schema__(:fields)

    season
    |> cast(attrs, fields)
    |> validate_required([:id, :year, :type])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Period do
  use Sportradar.Schema

  @embedded_fields [:scoring]

  embedded_schema do
    field :type, Ecto.Enum, values: [:QUARTER, :OVERTIME]
    field :id, :string
    field :number, :integer
    field :sequence, :integer

    embeds_one :scoring, Scoring
  end

  def changeset(period, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    period
    |> cast(attrs, fields)
    |> validate_required([:type, :id, :number, :sequence])
    |> cast_embed(:scoring)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Event do
  use Sportradar.Schema

  @embedded_fields [:attribution, :on_court]

  embedded_schema do
    field :id, :string
    field :clock, :string
    field :created, :string
    field :updated, :string
    field :description, :string
    field :wall_clock, :string
    field :sequence, :integer
    field :home_points, :integer
    field :away_points, :integer
    field :clock_decimal, :string
    field :number, :integer
    field :event_type, Ecto.Enum, values: [:SHOT, :FOUL, :REBOUND]

    embeds_one :attribution, TeamOrPlayer
    embeds_one :on_court, OnCourt
  end

  def changeset(event, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    event
    |> cast(attrs, fields)
    |> validate_required([:id, :clock, :sequence, :event_type])
    |> cast_embed(:attribution)
    |> cast_embed(:on_court)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.DeletedEvent do
  use Sportradar.Schema

  embedded_schema do
    field :id, :string
  end

  def changeset(deleted_event, attrs) do
    fields = __schema__(:fields)

    deleted_event
    |> cast(attrs, fields)
    |> validate_required([:id])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.TeamScore do
  use Sportradar.Schema

  embedded_schema do
    field :name, :string
    field :market, :string
    field :id, :string
    field :points, :integer
    field :reference, :string
  end

  def changeset(team_score, attrs) do
    fields = __schema__(:fields)

    team_score
    |> cast(attrs, fields)
    |> validate_required([:name, :id, :points])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.TeamOrPlayer do
  use Sportradar.Schema

  embedded_schema do
    field :name, :string
    field :market, :string
    field :id, :string
    field :sr_id, :string
    field :reference, :string
  end

  def changeset(team_or_player, attrs) do
    fields = __schema__(:fields)

    team_or_player
    |> cast(attrs, fields)
    |> validate_required([:name, :id])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.OnCourt do
  use Sportradar.Schema

  @embedded_fields [:home, :away]

  embedded_schema do
    embeds_one :home, TeamPlayers
    embeds_one :away, TeamPlayers
  end

  def changeset(on_court, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    on_court
    |> cast(attrs, fields)
    |> cast_embed(:home)
    |> cast_embed(:away)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.TeamPlayers do
  use Sportradar.Schema

  @embedded_fields [:players]

  embedded_schema do
    field :name, :string
    field :market, :string
    field :id, :string
    field :sr_id, :string
    field :reference, :string

    embeds_many :players, Player
  end

  def changeset(team_players, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    team_players
    |> cast(attrs, fields)
    |> validate_required([:name, :id])
    |> cast_embed(:players)
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Record do
  use Sportradar.Schema

  embedded_schema do
    field :wins, :integer
    field :losses, :integer
  end

  def changeset(record, attrs) do
    fields = __schema__(:fields)

    record
    |> cast(attrs, fields)
    |> validate_required([:wins, :losses])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Player do
  use Sportradar.Schema

  embedded_schema do
    field :full_name, :string
    field :jersey_number, :string
    field :id, :string
    field :sr_id, :string
    field :reference, :string
  end

  def changeset(player, attrs) do
    fields = __schema__(:fields)

    player
    |> cast(attrs, fields)
    |> validate_required([:full_name, :id])
  end
end

defmodule Sportradar.Sports.NBA.GamePBP.Scoring do
  use Sportradar.Schema

  @embedded_fields [:home, :away]

  embedded_schema do
    field :times_tied, :integer
    field :lead_changes, :integer
    embeds_one :home, TeamScore
    embeds_one :away, TeamScore
  end

  def changeset(scoring, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    scoring
    |> cast(attrs, fields)
    |> validate_required([])
    |> cast_embed(:home)
    |> cast_embed(:away)
  end
end
