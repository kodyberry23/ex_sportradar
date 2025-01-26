# Sportradar

An Elixir client library for the Sportradar API, providing convenient access to sports data with built-in schema validation and type safety.

## Features

- Built-in data validation using Ecto schemas
- Easy-to-use interface for making API requests
- Proper error handling and response parsing
- Type safety through embedded schemas

## Implemented Sports APIs

This is a comprehensive checklist of Sportradar sports APIs we plan to implement. Strikethrough indicates completed implementations with full test coverage and documentation.

### North American Sports
- Basketball
  - NBA (In Progress)
  - WNBA
  - NCAA Basketball
- Football
  - NFL
  - NCAA Football
- Baseball
  - MLB
  - NCAA Baseball
- Hockey
  - NHL
  - NCAA Hockey

### Soccer/Football
- International
  - FIFA World Cup
  - UEFA Champions League
  - UEFA Europa League
- European Leagues
  - English Premier League
  - La Liga
  - Bundesliga
  - Serie A
  - Ligue 1
- North American
  - MLS
  - Liga MX

### Other Sports
- Tennis
- Golf
- NASCAR
- Formula 1
- MMA/UFC
- Cricket
- Rugby

### Additional Coverage
- Odds & Betting
- Player Rankings
- Team Rankings
- News Feeds
- Images API Integration
- Real-time Data Feeds

## Installation

Add `ex_sportradar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_sportradar, "~> 0.1.0"}
  ]
end
```

## Configuration

Add your Sportradar API credentials to your config:

```elixir
# config/config.exs
config :ex_sportradar,
  api_key: "your_api_key"

# For different environments
config :ex_sportradar,
  api_key: System.get_env("SPORTRADAR_API_KEY")
```

## Documentation
The full documentation is available at https://hexdocs.pm/sportradar.

## Contributing

### Fork it

1. Create your feature branch (git checkout -b feature/my-new-feature)
2. Commit your changes (git commit -am 'Add some feature')
3. Push to the branch (git push origin feature/my-new-feature)
4. Create new Pull Request

### License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Credits

Developed and maintained by kodyberry23. Special thanks to all contributors.