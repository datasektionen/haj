defmodule Haj.Slack do
  require Logger

  def send_message(webhook_url, message) do
    if webhook_url do
      Logger.info("Sent slack message to #{webhook_url}")
      {_, res} = HTTPoison.post(webhook_url, "{\"text\":\"#{message}\"}", [{"Content-type", "application/json"}])
      Logger.debug(res)
    end
  end
end
