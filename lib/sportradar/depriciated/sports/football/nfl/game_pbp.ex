defmodule Sportradar.Sports.Football.NFL.GamePBP do
  use Sportradar.Schema

  @embedded_fields [:broadcast, :time_zones, :weather, :summary]

  embedded_schema do
    field(:id, :string)
    field(:status, :string)
    field(:scheduled, :string)
    field(:attendance, :integer)
    field(:entry_mode, :string)
    field(:clock, :string)
    field(:quarter, :integer)
    field(:sr_id, :string)
    field(:game_type, :string)
    field(:conference_game, :boolean)
    field(:duration, :string)

    embeds_one(:broadcast, Broadcast)
    embeds_one(:time_zones, TimeZones)
    embeds_one(:weather, Weather)
    embeds_one(:summary, Summary)
  end

  def changeset(pbp, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    pbp
    |> cast(attrs, fields)
    |> validate_required([:objectid, :status, :scheduled])
    |> cast_embed(:broadcast)
    |> cast_embed(:time_zones)
    |> cast_embed(:weather)
    |> cast_embed(:summary, required: true)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Broadcast do
  use Sportradar.Schema

  embedded_schema do
    field(:network, :string)
    field(:satellite, :string)
    field(:internet, :string)
    field(:radio, :string)
  end

  def changeset(broadcast, attrs) do
    fields = __schema__(:fields)

    broadcast
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.TimeZones do
  use Sportradar.Schema

  embedded_schema do
    field(:venue, :string)
    field(:home, :string)
    field(:away, :string)
  end

  def changeset(time_zones, attrs) do
    fields = __schema__(:fields)

    time_zones
    |> cast(attrs, fields)
    |> validate_required([:venue])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Weather do
  use Sportradar.Schema

  @embedded_fields [:wind]

  embedded_schema do
    field(:condition, :string)
    field(:humidity, :integer)
    field(:temp, :integer)

    embeds_one(:wind, Wind)
  end

  def changeset(weather, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    weather
    |> cast(attrs, fields)
    |> validate_required([])
    |> cast_embed(:wind)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Weather.Wind do
  use Sportradar.Schema

  embedded_schema do
    field(:speed, :integer)
    field(:direction, :string)
  end

  def changeset(wind, attrs) do
    fields = __schema__(:fields)

    wind
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Summary do
  use Sportradar.Schema

  @embedded_fields [:season, :week, :venue, :home, :away, :periods, :coin_toss, :pbp]

  embedded_schema do
    embeds_one(:season, Season)
    embeds_one(:week, Week)
    embeds_one(:venue, Venue)
    embeds_one(:home, Team)
    embeds_one(:away, Team)
    embeds_many(:periods, Period)
    embeds_one(:coin_toss, CoinToss)
    embeds_many(:pbp, PlayByPlay)
  end

  def changeset(summary, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    summary
    |> cast(attrs, fields)
    |> cast_embed(:season)
    |> cast_embed(:week)
    |> cast_embed(:venue)
    |> cast_embed(:home, required: true)
    |> cast_embed(:away, required: true)
    |> cast_embed(:periods)
    |> cast_embed(:coin_toss)
    |> cast_embed(:pbp)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Season do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:year, :integer)
    field(:type, :string)
    field(:name, :string)
  end

  def changeset(season, attrs) do
    fields = __schema__(:fields)

    season
    |> cast(attrs, fields)
    |> validate_required([:id, :year])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Week do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:sequence, :integer)
    field(:title, :string)
  end

  def changeset(week, attrs) do
    fields = __schema__(:fields)

    week
    |> cast(attrs, fields)
    |> validate_required([:id, :sequence])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Venue do
  use Sportradar.Schema

  @embedded_fields [:location]

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
    field(:zip, :string)
    field(:address, :string)
    field(:capacity, :integer)
    field(:surface, :string)
    field(:roof_type, :string)
    field(:sr_id, :string)

    embeds_one(:location, Location)
  end

  def changeset(venue, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    venue
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
    |> cast_embed(:location)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Location do
  use Sportradar.Schema

  embedded_schema do
    field(:lat, :string)
    field(:lng, :string)
  end

  def changeset(location, attrs) do
    fields = __schema__(:fields)

    location
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Team do
  use Sportradar.Schema

  @embedded_fields [:record]

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
    field(:used_timeouts, :integer)
    field(:remaining_timeouts, :integer)
    field(:points, :integer)
    field(:used_challenges, :integer)
    field(:remaining_challenges, :integer)

    embeds_one(:record, Record)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    team
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
    |> cast_embed(:record)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Record do
  use Sportradar.Schema

  embedded_schema do
    field(:wins, :integer)
    field(:losses, :integer)
    field(:ties, :integer)
  end

  def changeset(record, attrs) do
    fields = __schema__(:fields)

    record
    |> cast(attrs, fields)
    |> validate_required([:wins, :losses])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Period do
  use Sportradar.Schema

  @embedded_fields [:scoring]

  embedded_schema do
    field(:period_type, :string)
    field(:id, :string)
    field(:number, :integer)
    field(:sequence, :integer)

    embeds_one(:scoring, PeriodScoring)
  end

  def changeset(period, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    period
    |> cast(attrs, fields)
    |> validate_required([:id, :number])
    |> cast_embed(:scoring)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.PeriodScoring do
  use Sportradar.Schema

  @embedded_fields [:home, :away]

  embedded_schema do
    embeds_one(:home, ScoringTeam)
    embeds_one(:away, ScoringTeam)
  end

  def changeset(scoring, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    scoring
    |> cast(attrs, fields)
    |> cast_embed(:home)
    |> cast_embed(:away)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.ScoringTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
    field(:points, :integer)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([:id, :points])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.CoinToss do
  use Sportradar.Schema

  @embedded_fields [:home, :away]

  embedded_schema do
    embeds_one(:home, CoinTossTeam)
    embeds_one(:away, CoinTossTeam)
  end

  def changeset(coin_toss, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    coin_toss
    |> cast(attrs, fields)
    |> cast_embed(:home)
    |> cast_embed(:away)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.CoinTossTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:outcome, :string)
    field(:decision, :string)
    field(:direction, :string)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.PlayByPlay do
  use Sportradar.Schema

  @embedded_fields [:offensive_team, :defensive_team, :events]

  embedded_schema do
    field(:type, :string)
    field(:id, :string)
    field(:sequence, :integer)
    field(:start_reason, :string)
    field(:end_reason, :string)
    field(:play_count, :integer)
    field(:duration, :string)
    field(:first_downs, :integer)
    field(:gain, :integer)
    field(:penalty_yards, :integer)
    field(:created_at, :string)
    field(:updated_at, :string)
    field(:team_sequence, :integer)
    field(:start_clock, :string)
    field(:end_clock, :string)
    field(:first_drive_yardline, :integer)
    field(:last_drive_yardline, :integer)
    field(:farthest_drive_yardline, :integer)
    field(:net_yards, :integer)
    field(:pat_points_attempted, :integer)

    embeds_one(:offensive_team, OffensiveTeam)
    embeds_one(:defensive_team, DefensiveTeam)
    embeds_many(:events, Event)
  end

  def changeset(pbp, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    pbp
    |> cast(attrs, fields)
    |> validate_required([:id, :sequence])
    |> cast_embed(:offensive_team)
    |> cast_embed(:defensive_team)
    |> cast_embed(:events)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.OffensiveTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:points, :integer)
    field(:id, :string)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([:id])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.DefensiveTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:points, :integer)
    field(:id, :string)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([:id])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Event do
  use Sportradar.Schema

  @embedded_fields [:start_situation, :end_situation, :statistics]

  embedded_schema do
    field(:type, :string)
    field(:id, :string)
    field(:sequence, :integer)
    field(:clock, :string)
    field(:home_points, :integer)
    field(:away_points, :integer)
    field(:play_type, :string)
    field(:wall_clock, :string)
    field(:description, :string)
    field(:fake_punt, :boolean)
    field(:fake_field_goal, :boolean)
    field(:screen_pass, :boolean)
    field(:hash_mark, :string)
    field(:play_action, :boolean)
    field(:run_pass_option, :boolean)
    field(:created_at, :string)
    field(:updated_at, :string)
    field(:_comment, :string)

    embeds_one(:start_situation, Situation)
    embeds_one(:end_situation, Situation)
    embeds_many(:statistics, Statistics)
  end

  def changeset(event, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    event
    |> cast(attrs, fields)
    |> validate_required([:id, :sequence])
    |> cast_embed(:start_situation)
    |> cast_embed(:end_situation)
    |> cast_embed(:statistics)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Situation do
  use Sportradar.Schema

  @embedded_fields [:possession]

  embedded_schema do
    field(:clock, :string)
    field(:down, :integer)
    field(:yfd, :integer)

    embeds_one(:possession, Possession)
  end

  def changeset(situation, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    situation
    |> cast(attrs, fields)
    |> validate_required([])
    |> cast_embed(:possession)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Possession do
  use Sportradar.Schema

  @embedded_fields [:location]

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
    field(:yardline, :integer)

    embeds_one(:location, PossessionLocation)
  end

  def changeset(possession, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    possession
    |> cast(attrs, fields)
    |> validate_required([])
    |> cast_embed(:location)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.PossessionLocation do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
  end

  def changeset(location, attrs) do
    fields = __schema__(:fields)

    location
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.Statistics do
  use Sportradar.Schema

  @embedded_fields [:player, :details]

  embedded_schema do
    field(:stat_type, :string)
    field(:attempt, :integer)
    field(:yards, :integer)
    field(:net_yards, :integer)
    field(:touchback, :integer)
    field(:onside_attempt, :integer)
    field(:onside_success, :integer)
    field(:squib_kick, :integer)

    embeds_one(:player, StatisticsPlayer)
    embeds_many(:details, StatisticsDetails)
  end

  def changeset(statistics, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    statistics
    |> cast(attrs, fields)
    |> validate_required([:stat_type])
    |> cast_embed(:player)
    |> cast_embed(:details)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.StatisticsPlayer do
  use Sportradar.Schema

  @embedded_fields [:team]

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:jersey, :string)
    field(:position, :string)
    field(:sr_id, :string)

    embeds_one(:team, PlayerTeam)
  end

  def changeset(player, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    player
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
    |> cast_embed(:team)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.PlayerTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.StatisticsDetails do
  use Sportradar.Schema

  @embedded_fields [:start_location, :end_location, :players]

  embedded_schema do
    field(:category, :string)
    field(:description, :string)
    field(:sequence, :integer)
    field(:yards, :integer)
    field(:result, :string)

    embeds_one(:start_location, DetailsLocation)
    embeds_one(:end_location, DetailsLocation)
    embeds_many(:players, DetailsPlayer)
  end

  def changeset(details, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    details
    |> cast(attrs, fields)
    |> validate_required([:sequence])
    |> cast_embed(:start_location)
    |> cast_embed(:end_location)
    |> cast_embed(:players)
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.DetailsLocation do
  use Sportradar.Schema

  embedded_schema do
    field(:alias, :string)
    field(:yardline, :integer)
  end

  def changeset(location, attrs) do
    fields = __schema__(:fields)

    location
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.NFL.GamePBP.DetailsPlayer do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:jersey, :string)
    field(:position, :string)
    field(:sr_id, :string)
    field(:role, :string)
  end

  def changeset(player, attrs) do
    fields = __schema__(:fields)

    player
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
  end
end
