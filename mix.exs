defmodule Warlock.MixProject do
  use Mix.Project

  def project do
    [
      app: :warlock,
      version: "0.1.3",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.9", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.7", optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dummy, "~> 1.4", only: :test},
      {:jason, "~> 1.2"},
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  defp package do
    [
      name: :warlock,
      files: ~w(mix.exs lib .formatter.exs README.md LICENSE),
      maintainers: ["nomorepanic"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/strangemachines/warlock"}
    ]
  end

  defp description do
    "A library to build Plug-based APIs"
  end
end
