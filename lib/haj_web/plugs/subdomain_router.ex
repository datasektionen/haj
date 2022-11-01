defmodule HajWeb.Plugs.SubdomainRouter do
  @moduledoc "Extracts subdomains and puts them into `conn.private`"
  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{host: host} = conn, opts) do
    root_host = HajWeb.Endpoint.config(:url)[:host]
    haj_subdomain = Application.get_env(:haj, :haj_subdomain)

    case extract_subdomain(host, root_host) do
      subdomain when byte_size(subdomain) > 0 ->
        case subdomain do
          ^haj_subdomain -> HajWeb.Router.call(conn, opts)
        end

      _ ->
        HajWeb.PublicRouter.call(conn, opts)
    end
  end

  defp extract_subdomain(host, root_host) do
    # not the most efficient way
    String.replace(host, ~r/.?#{root_host}/, "")
  end
end
