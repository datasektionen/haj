defmodule HajWeb.GoogleApiController do
  use HajWeb, :controller

  alias Haj.GoogleApi

  def consent(conn, %{"code" => code, "state" => state} = _params) do
    with {:ok, _} <- GoogleApi.save_token(code, state) do
      conn
      |> put_status(200)
      |> render(:consent)
    else
      _ -> conn |> put_status(404) |> render(:error)
    end
  end
end
