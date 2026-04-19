defmodule HajWeb.RfingerController do
  use HajWeb, :controller

  def user_image(conn, %{"username" => username} = params) do
    quality = parse_quality(Map.get(params, "quality"))

    with {:ok, api_url} <- fetch_rfinger_api_url(),
         {:ok, api_key} <- fetch_rfinger_api_key(),
         {:ok, response} <- request_presigned_url(api_url, api_key, username, quality),
         {:ok, image_url} <- extract_presigned_url(response.body) do
      redirect(conn, external: image_url)
    else
      {:error, :missing_api_url} ->
        conn |> put_status(:internal_server_error) |> text("rfinger api url is not configured")

      {:error, :missing_api_key} ->
        conn |> put_status(:internal_server_error) |> text("rfinger api key is not configured")

      {:error, :invalid_presigned_url_response} ->
        send_resp(conn, 502, "")

      {:error, _reason} ->
        send_resp(conn, 502, "")
    end
  end

  defp request_presigned_url(api_url, api_key, username, quality) do
    url = "#{String.trim_trailing(api_url, "/")}/api/#{URI.encode_www_form(username)}"

    Req.get(
      url: url,
      headers: [{"authorization", "Bearer #{api_key}"}],
      params: [quality: quality]
    )
  end

  defp parse_quality(nil), do: false

  defp parse_quality(value) when value in [true, "true", "1", 1], do: true

  defp parse_quality(value) when value in [false, "false", "0", 0], do: false

  defp parse_quality(_value), do: false

  defp extract_presigned_url(url) when is_binary(url), do: {:ok, url}

  defp extract_presigned_url(%{"url" => url}) when is_binary(url), do: {:ok, url}

  defp extract_presigned_url(%{"data" => %{"url" => url}}) when is_binary(url), do: {:ok, url}

  defp extract_presigned_url(_body), do: {:error, :invalid_presigned_url_response}

  defp fetch_rfinger_api_url do
    case Application.get_env(:haj, :rfinger_api_url) || System.get_env("RFINGER_API_URL") do
      nil -> {:error, :missing_api_url}
      "" -> {:error, :missing_api_url}
      value -> {:ok, value}
    end
  end

  defp fetch_rfinger_api_key do
    case Application.get_env(:haj, :rfinger_api_key) || System.get_env("RFINGER_API_KEY") do
      nil -> {:error, :missing_api_key}
      "" -> {:error, :missing_api_key}
      value -> {:ok, value}
    end
  end
end
