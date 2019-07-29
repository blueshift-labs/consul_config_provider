defmodule Client.Mojito do
  @moduledoc "Http client using mojito"
  @behaviour Http
  @compile {:inline, request: 1}

  @impl true
  def request(request_opts) do
    case Mojito.request(request_opts) do
      {:ok, %Mojito.Response{body: body}} -> {:ok, body}
      {:error, any} -> {:error, any}
    end
  end
end
