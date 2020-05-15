defmodule ConsulConfigProvider.Http do
  @moduledoc "behaviour for http commands used in the application for mox and to make the http layer plugable"

  # the below takes any term due to the lack of a keyword_list guard
  @callback request(any()) :: {:ok, body :: String.t()} | {:error, any()}
end
