defmodule Sportradar.Sports.Football.Nfl.PushEvent do
  use Sportradar.Schema

  @embedded_fields [:payload, :metadata]

  embedded_schema do
    field(:locale, :string)

    embeds_one(:payload, Payload)
    embeds_one(:metadata, Metadata)
  end

  def changeset(push_event, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    push_event
    |> cast(attrs, fields)
    |> validate_required([:locale])
    |> cast_embed(:payload)
    |> cast_embed(:metadata)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Payload do
  use Sportradar.Schema

  @embedded_fields [:game, :event]

  embedded_schema do
    embeds_one(:game, Game)
    embeds_one(:event, Event)
  end

  def changeset(payload, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    payload
    |> cast(attrs, fields)
    |> validate_required([])
    |> cast_embed(:game)
    |> cast_embed(:event)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Game do
  use Sportradar.Schema

  @embedded_fields [:summary]

  embedded_schema do
    field(:id, :string)
    field(:status, :string)
    field(:coverage, :string)
    field(:game_type, :string)
    field(:scheduled, :string)
    field(:entry_mode, :string)
    field(:wx_temp, :integer)
    field(:wx_humidity, :integer)
    field(:wx_wind_speed, :integer)
    field(:wx_wind_direction, :string)
    field(:wx_condition, :string)
    field(:weather, :string)
    field(:quarter, :integer)
    field(:clock, :string)
    field(:sr_id, :string)

    embeds_one(:summary, GameSummary)
  end

  def changeset(game, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    game
    |> cast(attrs, fields)
    |> validate_required([:id, :status])
    |> cast_embed(:summary)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.GameSummary do
  use Sportradar.Schema

  @embedded_fields [:home, :away]

  embedded_schema do
    embeds_one(:home, Team)
    embeds_one(:away, Team)
  end

  def changeset(summary, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    summary
    |> cast(attrs, fields)
    |> cast_embed(:home)
    |> cast_embed(:away)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Team do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:used_timeouts, :integer)
    field(:remaining_timeouts, :integer)
    field(:points, :integer)
    field(:sr_id, :string)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Event do
  use Sportradar.Schema

  @embedded_fields [:period, :drive, :start_situation, :end_situation, :statistics, :details]

  embedded_schema do
    field(:type, :string)
    field(:id, :string)
    field(:sequence, :float)
    field(:clock, :string)
    field(:home_points, :integer)
    field(:away_points, :integer)
    field(:created_at, :string)
    field(:updated_at, :string)
    field(:play_type, :string)
    field(:wall_clock, :string)
    field(:source, :string)
    field(:fake_punt, :boolean)
    field(:fake_field_goal, :boolean)
    field(:screen_pass, :boolean)
    field(:play_action, :boolean)
    field(:run_pass_option, :boolean)
    field(:description, :string)

    embeds_one(:period, Period)
    embeds_one(:drive, Drive)
    embeds_one(:start_situation, Situation)
    embeds_one(:end_situation, Situation)
    embeds_many(:statistics, Statistic)
    embeds_many(:details, Detail)
  end

  def changeset(event, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    event
    |> cast(attrs, fields)
    |> validate_required([:id, :type, :sequence])
    |> cast_embed(:period)
    |> cast_embed(:drive)
    |> cast_embed(:start_situation)
    |> cast_embed(:end_situation)
    |> cast_embed(:statistics)
    |> cast_embed(:details)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Period do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:number, :integer)
    field(:sequence, :integer)
  end

  def changeset(period, attrs) do
    fields = __schema__(:fields)

    period
    |> cast(attrs, fields)
    |> validate_required([:id, :number])
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Drive do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:sequence, :integer)
    field(:start_reason, :string)
    field(:end_reason, :string)
    field(:play_count, :integer)
    field(:duration, :string)
    field(:first_downs, :integer)
    field(:gain, :integer)
    field(:penalty_yards, :integer)
  end

  def changeset(drive, attrs) do
    fields = __schema__(:fields)

    drive
    |> cast(attrs, fields)
    |> validate_required([:id, :sequence])
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Situation do
  use Sportradar.Schema

  @embedded_fields [:possession, :location]

  embedded_schema do
    field(:clock, :string)
    field(:down, :integer)
    field(:yfd, :integer)

    embeds_one(:possession, SituationTeam)
    embeds_one(:location, SituationTeam)
  end

  def changeset(situation, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    situation
    |> cast(attrs, fields)
    |> cast_embed(:possession)
    |> cast_embed(:location)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.SituationTeam do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:market, :string)
    field(:alias, :string)
    field(:sr_id, :string)
    field(:yardline, :integer)
  end

  def changeset(team, attrs) do
    fields = __schema__(:fields)

    team
    |> cast(attrs, fields)
    |> validate_required([])
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Statistic do
  use Sportradar.Schema

  @embedded_fields [:team, :player]

  embedded_schema do
    field(:stat_type, :string)
    field(:attempt, :integer)
    field(:yards, :integer)
    field(:net_yards, :integer)
    field(:touchback, :integer)
    field(:onside_attempt, :integer)
    field(:onside_success, :integer)
    field(:squib_kick, :integer)
    field(:firstdown, :integer)
    field(:inside_20, :integer)
    field(:goaltogo, :integer)
    field(:broken_tackles, :integer)
    field(:kneel_down, :integer)
    field(:scramble, :integer)
    field(:category, :string)
    field(:nullified, :boolean)
    field(:target, :integer)
    field(:catchable, :integer)
    field(:complete, :integer)
    field(:att_yards, :integer)
    field(:blitz, :integer)
    field(:hurry, :integer)
    field(:knockdown, :integer)
    field(:on_target_throw, :integer)
    field(:batted_pass, :integer)
    field(:penalty, :integer)
    field(:tackle, :integer)
    field(:def_target, :integer)
    field(:def_comp, :integer)

    embeds_one(:team, StatTeam)
    embeds_one(:player, StatPlayer)
  end

  def changeset(statistic, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    statistic
    |> cast(attrs, fields)
    |> validate_required([:stat_type])
    |> cast_embed(:team)
    |> cast_embed(:player)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.StatTeam do
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

defmodule Sportradar.Sports.Football.Nfl.PushEvent.StatPlayer do
  use Sportradar.Schema

  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:jersey, :string)
    field(:position, :string)
    field(:sr_id, :string)
  end

  def changeset(player, attrs) do
    fields = __schema__(:fields)

    player
    |> cast(attrs, fields)
    |> validate_required([:id, :name])
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Detail do
  use Sportradar.Schema

  @embedded_fields [:start_location, :end_location, :players, :penalty]

  embedded_schema do
    field(:category, :string)
    field(:description, :string)
    field(:sequence, :integer)
    field(:yards, :integer)
    field(:result, :string)
    field(:alt_description, :string)

    embeds_one(:start_location, Location)
    embeds_one(:end_location, Location)
    embeds_many(:players, DetailPlayer)
    embeds_one(:penalty, Penalty)
  end

  def changeset(detail, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    detail
    |> cast(attrs, fields)
    |> validate_required([:sequence])
    |> cast_embed(:start_location)
    |> cast_embed(:end_location)
    |> cast_embed(:players)
    |> cast_embed(:penalty)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Location do
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

defmodule Sportradar.Sports.Football.Nfl.PushEvent.DetailPlayer do
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

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Penalty do
  use Sportradar.Schema

  @embedded_fields [:team]

  embedded_schema do
    field(:description, :string)
    field(:result, :string)
    field(:yards, :integer)

    embeds_one(:team, StatTeam)
  end

  def changeset(penalty, attrs) do
    fields = __schema__(:fields) -- @embedded_fields

    penalty
    |> cast(attrs, fields)
    |> validate_required([:description])
    |> cast_embed(:team)
  end
end

defmodule Sportradar.Sports.Football.Nfl.PushEvent.Metadata do
  use Sportradar.Schema

  embedded_schema do
    field(:league, :string)
    field(:match, :string)
    field(:status, :string)
    field(:event_type, :string)
    field(:event_category, :string)
    field(:locale, :string)
    field(:operation, :string)
    field(:version, :string)
    field(:team, :string)
  end

  def changeset(metadata, attrs) do
    fields = __schema__(:fields)

    metadata
    |> cast(attrs, fields)
    |> validate_required([:league, :match, :status, :operation, :version])
  end
end
