defmodule ConsulConfigProvider.Client.Mojito do
  @moduledoc "Http client using mojito"
  @behaviour ConsulConfigProvider.Http
  @compile {:inline, request: 1}

  if match?({:module, _}, Code.ensure_compiled(Mojito)) do
    @impl true
    def request(request_opts) do
      case Mojito.request(request_opts) do
        {:ok, %Mojito.Response{body: body}} -> {:ok, body}
        {:error, any} -> {:error, any}
      end
    end
  else
    @impl true
    def request(_request_opts) do
      {:error, :mojito_not_compiled}
    end
  end
end
