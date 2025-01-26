defmodule Sportradar.Sports.Basketball.NBA.BoxScore do
  use Sportradar.Schema

  @embedded_fields [:broadcasts, :season, :time_zones, :home, :away]

  embedded_schema do
    field(:id, :string)
    field(:status, :string)
    field(:coverage, :string)
    field(:neutral_site, :boolean)
    field(:reference, :string)
    field(:game_lineup, :boolean)
    field(:parent_id, :string)
    field(:scheduled, :string)
    field(:inseason_tournament, :boolean)
    field(:entry_mode, :string)
    field(:attendance, :integer)
    field(:lead_changes, :integer)
    field(:times_tied, :integer)
    field(:clock, :string)
    field(:quarter, :integer)
    field(:clock_fraction, :integer)
    field(:clock_decimal, :string)
    field(:venue, :string)

    embeds_many(:broadcasts, Broadcast)
    embeds_one(:season, Season)
    embeds_one(:time_zones, TimeZones)
    embeds_one(:home, Team)
    embeds_one(:away, Team)
  end

  def changeset(box_score, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    box_score
    |> cast(attrs, fields)
    |> validate_required([:id, :status, :scheduled])
    |> cast_embed(:broadcasts)
    |> cast_embed(:season)
    |> cast_embed(:time_zones)
    |> cast_embed(:home, required: true)
    |> cast_embed(:away, required: true)
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Broadcast do
  use Sportradar.Schema

  embedded_schema do
    field(:network, :string)
    field(:type, :string)
    field(:locale, :string)
    field(:channel, :string)
  end

  def changeset(broadcast, attrs) do
    fields = __schema__(:fields)

    broadcast
    |> cast(attrs, fields)
    |> validate_required([:network, :type])
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Season do
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
    |> validate_required([:id, :year, :type])
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.TimeZones do
  use Sportradar.Schema

  embedded_schema do
    field(:venue, :string)
  end

  def changeset(time_zones, attrs) do
    fields = __schema__(:fields)

    time_zones
    |> cast(attrs, fields)
    |> validate_required([:venue])
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Team do
  use Sportradar.Schema

  @embedded_fields [:record, :scoring]

  embedded_schema do
    field(:name, :string)
    field(:market, :string)
    field(:reference, :string)
    field(:alias, :string)
    field(:id, :string)
    field(:points, :integer)
    field(:bonus, :boolean)
    field(:remaining_timeouts, :integer)

    embeds_one(:record, Record)
    embeds_many(:scoring, Scoring)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    team
    |> cast(attrs, fields)
    |> validate_required([:name, :id])
    |> cast_embed(:record)
    |> cast_embed(:scoring)
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Record do
  use Sportradar.Schema

  embedded_schema do
    field(:wins, :integer)
    field(:losses, :integer)
  end

  def changeset(record, attrs) do
    fields = __schema__(:fields)

    record
    |> cast(attrs, fields)
    |> validate_required([:wins, :losses])
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Scoring do
  use Sportradar.Schema

  @embedded_fields [:leaders]

  embedded_schema do
    field(:number, :integer)
    field(:sequence, :integer)
    field(:points, :integer)
    field(:type, :string)

    embeds_one(:leaders, Leaders)
  end

  def changeset(scoring, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    scoring
    |> cast(attrs, fields)
    |> validate_required([:number, :sequence, :points, :type])
    |> cast_embed(:leaders)
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Leaders do
  use Sportradar.Schema

  @embedded_fields [:points, :rebounds, :assists]

  embedded_schema do
    embeds_many(:points, PlayerStatistics)
    embeds_many(:rebounds, PlayerStatistics)
    embeds_many(:assists, PlayerStatistics)
  end

  def changeset(leaders, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    leaders
    |> cast(attrs, fields)
    |> cast_embed(:points)
    |> cast_embed(:rebounds)
    |> cast_embed(:assists)
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.PlayerStatistics do
  use Sportradar.Schema

  @embedded_fields [:statistics]

  embedded_schema do
    field(:full_name, :string)
    field(:position, :string)
    field(:primary_position, :string)
    field(:jersey_number, :string)
    field(:reference, :string)
    field(:id, :string)

    embeds_one(:statistics, Statistics)
  end

  def changeset(player_statistics, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    player_statistics
    |> cast(attrs, fields)
    |> validate_required([:full_name, :id])
    |> cast_embed(:statistics)
  end
end

defmodule Sportradar.Sports.NBA.BoxScore.Statistics do
  use Sportradar.Schema

  embedded_schema do
    field(:minutes, :string)
    field(:field_goals_made, :integer)
    field(:field_goals_att, :integer)
    field(:field_goals_pct, :float)
    field(:effective_fg_pct, :float)
    field(:three_points_made, :integer)
    field(:three_points_att, :integer)
    field(:three_points_pct, :float)
    field(:two_points_made, :integer)
    field(:two_points_att, :integer)
    field(:two_points_pct, :float)
    field(:blocked_att, :integer)
    field(:free_throws_made, :integer)
    field(:free_throws_att, :integer)
    field(:free_throws_pct, :float)
    field(:offensive_rebounds, :integer)
    field(:defensive_rebounds, :integer)
    field(:rebounds, :integer)
    field(:assists, :integer)
    field(:turnovers, :integer)
    field(:steals, :integer)
    field(:blocks, :integer)
    field(:assists_turnover_ratio, :float)
    field(:fouls_drawn, :integer)
    field(:personal_fouls, :integer)
    field(:offensive_fouls, :integer)
    field(:tech_fouls, :integer)
    field(:tech_fouls_non_unsportsmanlike, :integer)
    field(:flagrant_fouls, :integer)
    field(:pls_min, :integer)
    field(:points, :integer)
    field(:second_chance_pts, :integer)
    field(:points_off_turnovers, :integer)
    field(:points_in_paint, :integer)
    field(:points_in_paint_att, :integer)
    field(:points_in_paint_made, :integer)
    field(:points_in_paint_pct, :float)
    field(:double_double, :boolean)
    field(:triple_double, :boolean)
    field(:efficiency, :integer)
    field(:efficiency_game_score, :float)
    field(:true_shooting_att, :integer)
    field(:true_shooting_pct, :float)
    field(:defensive_rating, :integer)
    field(:coach_ejections, :integer)
    field(:offensive_rating, :integer)
    field(:fast_break_pts, :integer)
    field(:fast_break_att, :integer)
    field(:fast_break_made, :integer)
    field(:fast_break_pct, :float)
    field(:second_chance_att, :integer)
    field(:second_chance_made, :integer)
    field(:second_chance_pct, :float)
    field(:minus, :integer)
    field(:plus, :integer)
    field(:defensive_rebounds_pct, :float)
    field(:offensive_rebounds_pct, :float)
    field(:rebounds_pct, :float)
    field(:steals_pct, :float)
    field(:turnovers_pct, :float)
    field(:coach_tech_fouls, :integer)
  end

  def changeset(statistics, attrs) do
    fields = __schema__(:fields)

    statistics
    |> cast(attrs, fields)
    |> validate_required([:minutes, :points])
  end
end
