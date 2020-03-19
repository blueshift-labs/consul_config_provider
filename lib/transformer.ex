defmodule ConsulConfigProvider.Transformer do
  @moduledoc "behaviour for transforming keyword values into any data types"

  @callback transform(keyword()) :: keyword()
end
