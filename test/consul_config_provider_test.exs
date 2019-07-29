defmodule ConsulConfigProviderTest do
  use ExUnit.Case
  use ExUnitProperties

  import Mox

  setup :verify_on_exit!

  property "load/2 returns a config namespaced on app_name given a prefix with configs ending in .json for non-dependency configs" do
    check all(
            app_name <- atom(:alphanumeric),
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

      HttpMock
      |> expect(:request, 2, fn args ->
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

      new_config = ConsulConfigProvider.load([], %{prefix: prefix, app_name: app_name})

      assert get_in(new_config, [
               app_name,
               String.to_atom(config_name),
               String.to_atom(config_key)
             ]) == config_value
    end
  end
end
