defmodule ConsulConfigProvider.MixProject do
  use Mix.Project

  def project do
    [
      app: :consul_config_provider,
      version: "0.1.5",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "Consul Config Provider",
      source_url: "https://github.com/blueshift-labs/consul_config_provider",
      homepage_url: "https://github.com/blueshift-labs/consul_config_provider",
      docs: [
        # The main page in the docs
        main: "ConsulConfigProvider",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
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
      {:jason, "~> 1.0"},
      {:mojito, "~> 0.6.0", optional: true},
      {:yaml_elixir, "~> 2.3"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:mox, "~> 0.5", only: :test},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end

  defp description() do
    "A simple somewhat opinionated consul config provider for elixir 1.9+ releases."
  end

  defp package() do
    [
      name: "consul_config_provider",
      files: ~w(lib doc .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/blueshift-labs/consul_config_provider"},
      source_url: "https://github.com/blueshift-labs/consul_config_provider"
    ]
  end
end
