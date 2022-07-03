defmodule ConsulConfigProviderTest do
  use ExUnit.Case
  use ExUnitProperties

  import Mox

  setup :verify_on_exit!

  property "load/2 returns the updated config" do
    check all(
            prefix <- string(:alphanumeric, min_length: 1),
            config_key <- string(:alphanumeric, min_length: 1),
            config_value <- string(:alphanumeric, min_length: 1),
            config_name <- string(:alphanumeric, min_length: 1)
          ) do
      encoded_value =
        %{config_key => config_value}
        |> Jason.encode!()
        |> Base.encode64()

      encoded_config =
        [
          %{
            "CreateIndex" => 12,
            "Flags" => 0,
            "Key" => "#{prefix}/#{config_name}.json",
            "LockIndex" => 0,
            "ModifyIndex" => 1,
            "Value" => encoded_value
          }
        ]
        |> Jason.encode!()

      expect(ConsulConfigProvider.HttpMock, :request, 2, fn args ->
        url = Keyword.get(args, :url)

        case String.contains?(url, "?keys=true") do
          true ->
            # initial call to get keys
            {:ok, "[\"#{prefix}/#{config_name}.json\"]"}

          false ->
            # other call(s) to get key values
            {:ok, encoded_config}
        end
      end)

      new_config =
        ConsulConfigProvider.load(
          [consul_config_provider: Application.get_all_env(:consul_config_provider)],
          %{prefix: prefix}
        )

      assert get_in(new_config, [
               String.to_atom(config_name),
               String.to_atom(config_key)
             ]) == config_value
    end
  end
end
