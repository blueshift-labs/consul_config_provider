defmodule ConsulConfigProvider do
  @moduledoc "A consul config provider for Elixir 1.9+ assuming the configs have an extension in the key name"
  @behaviour Config.Provider
  @dialyzer {:nowarn_function, load: 2}

  @impl true
  def init(%{prefix: prefix, app_name: app_name} = consul_config)
      when is_binary(prefix) and is_atom(app_name),
      do: consul_config

  @impl true
  def load(config, %{prefix: prefix, app_name: app_name}) do
    host = System.get_env("CONSUL_HOST", "localhost")
    port = System.get_env("CONSUL_PORT", "8500") |> String.to_integer()
    prefix = System.get_env("CONSUL_PREFIX", prefix)
    keys_url = "http://#{host}:#{port}/v1/kv/#{prefix}?keys=true"
    http_module = Application.get_env(:consul_config_provider, :http_module, Client.Mojito)

    {:ok, body} = http_module.request(method: :get, url: keys_url, opts: [pool: false])

    consul_configs =
      body
      |> Jason.decode!()
      |> Enum.reduce([], fn path, acc ->
        if String.ends_with?(path, "/") do
          acc
        else
          [String.replace_leading(path, prefix <> "/", "") | acc]
        end
      end)
      |> Enum.map(
        &Task.async(fn ->
          get_consul_key(http_module, host, port, prefix, &1)
        end)
      )
      |> Enum.map(&Task.await/1)

    applications = Application.spec(app_name, :applications) || []

    {deps_configs, app_configs} =
      Enum.reduce(consul_configs, {[], []}, fn {key, _} = config, {deps_configs, app_configs} ->
        if key in applications do
          {[config | deps_configs], app_configs}
        else
          {deps_configs, [config | app_configs]}
        end
      end)

    Config.Reader.merge(
      config,
      [{app_name, app_configs} | deps_configs]
    )
  end

  defp get_consul_key(http_module, host, port, prefix, key_name) do
    url = "http://#{host}:#{port}/v1/kv/#{prefix}/#{key_name}"
    {:ok, body} = http_module.request(method: :get, url: url, opts: [pool: false])

    key_val =
      body
      |> Jason.decode!()
      |> hd()
      |> Map.get("Value")
      |> Base.decode64!()

    new_config =
      key_name
      |> Path.extname()
      |> case do
        ".json" ->
          key_val |> Jason.decode!() |> Map.to_list()

        ".yml" ->
          key_val |> YamlElixir.read_from_string!(maps_as_keywords: true)

        ".yaml" ->
          key_val |> YamlElixir.read_from_string!(maps_as_keywords: true)

        _ ->
          raise "unsupported config format"
      end
      |> string_atoms()

    config_prefix =
      key_name
      |> Path.rootname()
      |> String.to_atom()

    {config_prefix, new_config}
  end

  defp string_atoms(list, acc \\ [])

  defp string_atoms([], acc) do
    Enum.reverse(acc)
  end

  defp string_atoms([{str, val} | rest], acc) when is_binary(str) and is_list(val) do
    string_atoms(rest, [{String.to_atom(str), string_atoms(val)} | acc])
  end

  defp string_atoms([{str, val} | rest], acc) when is_binary(str) do
    string_atoms(rest, [{String.to_atom(str), val} | acc])
  end

  defp string_atoms([item | rest], acc) do
    string_atoms(rest, [item | acc])
  end
end
