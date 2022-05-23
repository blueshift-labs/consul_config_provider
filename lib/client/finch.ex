defmodule ConsulConfigProvider.Client.Finch do
  @moduledoc "Http client using finch"
  @behaviour ConsulConfigProvider.Http
  @compile {:inline, request: 1}

  if match?({:module, _}, Code.ensure_compiled(Finch)) do
    @impl true
    def request(method: method, url: url) do
      {:ok, _} = Application.ensure_all_started(:telemetry)
      pid = Process.whereis(ConsulConfigDefaultHTTPClient)

      if pid == nil do
        Finch.start_link(name: ConsulConfigDefaultHTTPClient)
      end

      headers = [{"Content-Type", "application/json"}]
      pool_opts = %{default: [max_idle_time: 60_000, size: 10, count: 1]}
      finch_req = Finch.build(method, url, headers, nil, [pools: pool_opts])
      {:ok, %Finch.Response{body: body}} = Finch.request(finch_req, ConsulConfigDefaultHTTPClient)
      {:ok, body}
    end
  else
    @impl true
    def request(_request_opts) do
      {:error, :finch_not_compiled}
    end
  end
end
