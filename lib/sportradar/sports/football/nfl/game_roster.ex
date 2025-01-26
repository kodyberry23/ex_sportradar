defmodule Sportradar.Sports.Football.Nfl.GameRoster do
  use Sportradar.Schema

  @embedded_fields [:broadcast, :time_zones, :weather, :summary]

  embedded_schema do
    field(:objectid, :string)
    field(:status, :string)
    field(:scheduled, :string)
    field(:attendance, :integer)
    field(:entry_mode, :string)
    field(:clock, :string)
    field(:quarter, :integer)
    field(:sr_id, :string)
    field(:game_type, :string)
    field(:duration, :string)

    embeds_one(:broadcast, Broadcast)
    embeds_one(:time_zones, TimeZones)
    embeds_one(:weather, Weather)
    embeds_one(:summary, Summary)
  end

  def changeset(roster, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    roster
    |> cast(attrs, fields)
    |> validate_required([:objectid, :status, :scheduled])
    |> cast_embed(:broadcast)
    |> cast_embed(:time_zones)
    |> cast_embed(:weather)
    |> cast_embed(:summary, required: true)
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Broadcast do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.TimeZones do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Weather do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Weather.Wind do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Summary do
  use Sportradar.Schema

  @embedded_fields [:season, :week, :venue, :home, :away, :draft, :officials]

  embedded_schema do
    field(:_comment, :string)

    embeds_one(:season, Season)
    embeds_one(:week, Week)
    embeds_one(:venue, Venue)
    embeds_one(:home, Team)
    embeds_one(:away, Team)
    embeds_one(:draft, Draft)
    embeds_many(:officials, Official)
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
    |> cast_embed(:draft)
    |> cast_embed(:officials)
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Season do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Week do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Venue do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Location do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Team do
  use Sportradar.Schema

  @embedded_fields [:coaches, :players]

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)

    embeds_many(:coaches, Coach)
    embeds_many(:players, Player)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    team
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
    |> cast_embed(:coaches)
    |> cast_embed(:players)
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Coach do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:full_name, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:position, :string)
  end

  def changeset(coach, attrs) do
    fields = __schema__(:fields)

    coach
    |> cast(attrs, fields)
    |> validate_required([:id, :full_name])
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Player do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:jersey, :string)
    field(:last_name, :string)
    field(:role, :string)
    field(:first_name, :string)
    field(:abbr_name, :string)
    field(:preferred_name, :string)
    field(:birth_date, :string)
    field(:weight, :integer)
    field(:height, :integer)
    field(:position, :string)
    field(:age, :integer)
    field(:birth_place, :string)
    field(:high_school, :string)
    field(:college, :string)
    field(:college_conf, :string)
    field(:rookie_year, :integer)
    field(:status, :string)
    field(:sr_id, :string)
  end

  def changeset(player, attrs) do
    fields = __schema__(:fields)

    player
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Draft do
  use Sportradar.Schema

  @embedded_fields [:team]

  embedded_schema do
    field(:year, :integer)
    field(:round, :integer)
    field(:number, :integer)

    embeds_one(:team, DraftTeam)
  end

  def changeset(draft, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    draft
    |> cast(attrs, fields)
    |> validate_required([:year, :round])
    |> cast_embed(:team)
  end
end

defmodule Sportradar.Sports.Football.Nfl.GameRoster.DraftTeam do
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

defmodule Sportradar.Sports.Football.Nfl.GameRoster.Official do
  use Sportradar.Schema

  embedded_schema do
    field(:full_name, :string)
    field(:number, :string)
    field(:assignment, :string)
  end

  def changeset(official, attrs) do
    fields = __schema__(:fields)

    official
    |> cast(attrs, fields)
    |> validate_required([:full_name, :assignment])
  end
end
