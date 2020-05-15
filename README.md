# ConsulConfigProvider

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex pm](http://img.shields.io/hexpm/v/consul_config_provider.svg?style=flat)](https://hex.pm/packages/consul_config_provider)
[![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat)](https://hexdocs.pm/consul_config_provider/)

## Installation

The package can be installed by adding `consul_config_provider` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:consul_config_provider, "~> 0.1.4"},
    {:mojito, "~> 0.6.0"}, # default implmentation for http client
  ]
end
```
* Only add in mojito if you want to use the default http behaviour and not define your own client

The docs can be found at [https://hexdocs.pm/consul_config_provider](https://hexdocs.pm/consul_config_provider).

### Sample Usage

* In mix.exs
```elixir
releases: [
  release_name: [
    include_executables_for: [:unix],
    applications: [
      runtime_tools: :permanent,
      app_name_here: :permanent
    ],
    config_providers: [
      {ConsulConfigProvider,
       %{prefix: "services/app_namespace_in_consul/v1", app_name: :app_name_here}}
    ]
  ]
],
```

### Transformer
- You can also implement an optional transformer behaviour to change the form of your configs.
- This is helpful for interopt with erlang modules that might have different opinions about things

```elixir
defmodule Example.Config do
  @behaviour ConsulConfigProvider.Transformer

  @impl true
  def transform({:erlkaf, [clients: [producer: [client_options: client_options]]]}) do
    default_client_options =
      Application.get_env(:erlkaf, :clients, [])
      |> Keyword.get(:producer, [])
      |> Keyword.get(:client_options, [])

    {:erlkaf,
     [
       clients: [
         producer: [
           type: :producer,
           client_options: Keyword.merge(default_client_options, client_options)
         ]
       ]
     ]}
  end

  @impl true
  def transform(config), do: config
end
```

Then in your configs:
```elixir
config :consul_config_provider, transformer_module: Example.Config
```

### Information
* This provider assumes the config name has a file extension which is either `.json`, `.yml`, or `.yaml` no other extensions are supported although PRs would be welcomed. If you do not follow this naming convention the provider will not work and throw.
* In the above the `prefix` is used for the keys path and can also be set with `CONSUL_PREFIX` (provide an empty string to the prefix if you wish to just use the env var)
* The `CONSUL_HOST` env var is used for the host to talk to consul and defaults to localhost
* The `CONSUL_PORT` env var is used for the port to talk to consul and defaults to 8500
* The http_module is dynamic and you can specify your own if you choose to do so. Just implement the HTTP behaviour and make your implementation return an `{:ok, json_body_binary_string}` as per the mojito example which will be the fallback. You might have to deal with coercing the input keyword list for the mojito arguments to support the client you are using, as well. You also need to set `config :consul_config_provider, :http_module, Client.YourClient` pointing to your client in your configs.
* Dependency-related configs are namespaced with their own application name while other configs use the input app_name for their namespace
