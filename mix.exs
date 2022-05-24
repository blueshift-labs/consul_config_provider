defmodule ConsulConfigProvider.MixProject do
  use Mix.Project

  def project do
    [
      app: :consul_config_provider,
      version: "0.2.4",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "Consul Config Provider",
      source_url: "https://github.com/blueshift-labs/consul_config_provider",
      homepage_url: "https://github.com/blueshift-labs/consul_config_provider",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telemetry, "~> 1.1"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:jason, "~> 1.3"},
      {:mox, "~> 1.0", only: :test},
      {:stream_data, "~> 0.5", only: :test},
      {:yaml_elixir, "~> 2.9"},
      {:finch, "~> 0.12", optional: true}
    ]
  end

  defp description() do
    "A simple somewhat opinionated consul config provider for elixir 1.9+ releases."
  end

  defp package() do
    [
      name: "consul_config_provider",
      files: ~w(lib doc .formatter.exs mix.exs README* LICENSE* CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/blueshift-labs/consul_config_provider"},
      source_url: "https://github.com/blueshift-labs/consul_config_provider"
    ]
  end

  defp docs() do
    [
      # The main page in the docs
      main: "readme",
      source_ref: "master",

      # logo: "path/to/logo.png",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
