defmodule Sportradar.Mix.Tasks.Sportradar.Gen.Schemas do
  @moduledoc """
  Generates Elixir modules from Sportradar JSON schemas stored in priv/schemas.

  This task reads JSON schemas (previously converted from XSD files) and generates
  corresponding Elixir modules with appropriate types and structs. The schemas
  should be organized by sport, league, and version in the priv/schemas directory.

  ## Usage

      mix sportradar.gen.schemas --sport basketball --league nba --version v8

  ## Command Line Options

      * --sport    - Required. The sport to generate schemas for (e.g., basketball)
      * --league   - Required. The league to generate schemas for (e.g., nba)
      * --version  - Required. The version to generate schemas for (e.g., v8)
      * --output   - Optional. Output directory for generated files
                    (defaults to lib/sportradar/sports)

  ## Directory Structure

  Expected schema location:
      priv/schemas/<sport>/<league>/<version>/*.json

  Generated files location:
      lib/sportradar/sports/<sport>/<league>/<version>/*.ex

  ## Example

      mix sportradar.gen.schemas --sport basketball --league nba --version v8

  This will:
  1. Read JSON schemas from priv/schemas/basketball/nba/v8/
  2. Generate Elixir modules in lib/sportradar/sports/basketball/nba/v8/
  """

  use Mix.Task
  require Logger

  @shortdoc "Generates Elixir modules from Sportradar JSON schemas"

  @impl Mix.Task
  def run(args) do
    {opts, _} = parse_args(args)
    validate_required_options!(opts)

    Logger.info("Generating Elixir modules for #{opts[:sport]}/#{opts[:league]}/#{opts[:version]}")

    # Build paths and ensure directories exist
    schema_dir = build_schema_dir(opts)
    output_dir = build_output_dir(opts)
    File.mkdir_p!(output_dir)

    # Process all schemas in the correct order
    process_schemas(schema_dir, output_dir, opts)
  end

  defp parse_args(args) do
    OptionParser.parse!(args,
      strict: [
        sport: :string,
        league: :string,
        version: :string,
        output: :string
      ]
    )
  end

  defp validate_required_options!(opts) do
    Enum.each([:sport, :league, :version], fn required_opt ->
      unless opts[required_opt] do
        raise Mix.Error, "Missing required option: --#{required_opt}"
      end
    end)
  end

  defp build_schema_dir(opts) do
    Path.join([
      Application.app_dir(:sportradar, "priv"),
      "schemas",
      opts[:sport],
      opts[:league],
      opts[:version]
    ])
  end

  defp build_output_dir(opts) do
    base_dir = opts[:output] || "lib/sportradar/sports"
    Path.join([base_dir, opts[:sport], opts[:league], opts[:version]])
  end

  defp process_schemas(schema_dir, output_dir, opts) do
    # First process any common schemas as they may define base types
    process_schema_group("common", schema_dir, output_dir, opts)

    # Then process all other schemas
    process_schema_group("specific", schema_dir, output_dir, opts)

    Logger.info("Schema generation completed successfully!")
  end

  defp process_schema_group(group_type, schema_dir, output_dir, opts) do
    pattern = case group_type do
      "common" -> "#{schema_dir}/common*.json"
      "specific" -> "#{schema_dir}/[^common]*.json"
    end

    Path.wildcard(pattern)
    |> Enum.sort()
    |> Enum.each(&process_single_schema(&1, output_dir, opts))
  end

  defp process_single_schema(schema_path, output_dir, opts) do
    Logger.info("Processing schema: #{Path.basename(schema_path)}")

    # Read and parse the JSON schema
    schema =
      schema_path
      |> File.read!()
      |> Jason.decode!()

    # Generate Elixir module
    module_name = generate_module_name(schema_path, opts)
    code = generate_module_code(module_name, schema)

    # Write the module file
    output_path = Path.join(output_dir, generate_filename(schema_path))
    File.write!(output_path, code)

    Logger.info("Generated: #{module_name}")
  end

  defp generate_module_name(schema_path, opts) do
    base_name =
      schema_path
      |> Path.basename(".json")
      |> String.split(["-", "_"])
      |> Enum.map(&Macro.camelize/1)
      |> Enum.join(".")

    [
      "Sportradar",
      "Sports",
      Macro.camelize(opts[:sport]),
      String.upcase(opts[:league]),
      String.upcase(opts[:version]),
      base_name
    ]
    |> Enum.join(".")
  end

  defp generate_filename(schema_path) do
    schema_path
    |> Path.basename(".json")
    |> Macro.underscore()
    |> Kernel.<>(".ex")
  end

  defp generate_module_code(module_name, schema) do
    """
    defmodule #{module_name} do
      @moduledoc \"\"\"
      Generated from Sportradar schema.
      Original schema: #{schema["title"] || "Untitled"}
      \"\"\"

      #{generate_types(schema)}

      #{generate_structs(schema)}
    end
    """
  end

  # Type generation from JSON schema
  defp generate_types(schema) do
    definitions = schema["definitions"] || %{}

    definitions
    |> Enum.map(&generate_type/1)
    |> Enum.join("\n\n")
  end

  defp generate_type({name, definition}) do
    """
    @type #{String.downcase(name)} :: #{generate_type_spec(definition)}
    """
  end

  defp generate_type_spec(%{"type" => "object", "properties" => props}) do
    prop_types =
      props
      |> Enum.map(fn {prop_name, prop_def} ->
        "#{prop_name}: #{generate_type_spec(prop_def)}"
      end)
      |> Enum.join(", ")

    "%{#{prop_types}}"
  end

  defp generate_type_spec(%{"type" => "array", "items" => items}) do
    "[#{generate_type_spec(items)}]"
  end

  defp generate_type_spec(%{"type" => "string"}) do
    "String.t()"
  end

  defp generate_type_spec(%{"type" => "number"}) do
    "number()"
  end

  defp generate_type_spec(%{"type" => "integer"}) do
    "integer()"
  end

  defp generate_type_spec(%{"type" => "boolean"}) do
    "boolean()"
  end

  # Struct generation from JSON schema
  defp generate_structs(schema) do
    definitions = schema["definitions"] || %{}

    definitions
    |> Enum.map(&generate_struct/1)
    |> Enum.join("\n\n")
  end

  defp generate_struct({name, definition}) do
    props = definition["properties"] || %{}

    fields =
      props
      |> Enum.map(fn {field_name, _} -> "#{field_name}: nil" end)
      |> Enum.join(", ")

    """
    defstruct #{fields}
    """
  end
end
