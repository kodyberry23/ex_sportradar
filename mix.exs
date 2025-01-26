defmodule Sportradar.MixProject do
  use Mix.Project

  def project do
    [
      app: :sportradar,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "ExSportradar",
      source_url: "https://github.com/kodyberry23/ex_sportradar"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.0"},
      {:hackney, "~> 1.0", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:ecto, "~> 3.0"},
      {:phoenix_pubsub, "~> 2.0", optional: true},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false, optional: true}
    ]
  end

  defp description() do
    "Sportradar API client library for Elixir."
  end


  defp package do
    [
      name: "ex_sportradar",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kodyberry23/ex_sportradar"}
    ]
  end
end
