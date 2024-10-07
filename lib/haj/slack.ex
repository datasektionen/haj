defmodule Haj.Slack do
  require Logger

  @doc """
  Sends a message to a slack webhook url
  """
  def send_message!(webhook_url, message) do
    if webhook_url do
      Logger.info("Sending slack message to #{webhook_url}")

      res =
        Req.post!(webhook_url,
          json: %{"text" => message},
          headers: [
            {"Content-type", "application/json"}
          ]
        )

      Logger.debug(res)
    end
  end
end
