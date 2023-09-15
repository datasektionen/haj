defmodule Haj.Slack do
  require Logger

  @doc """
  Sends a message to a slack webhook url
  """
  def send_message(webhook_url, message) do
    if webhook_url do
      Logger.info("Sending slack message to #{webhook_url}")

      {_, res} =
        HTTPoison.post(webhook_url, "{\"text\":\"#{message}\"}", [
          {"Content-type", "application/json"}
        ])

      Logger.debug(res)
    end
  end

  def application_message(user, application, show_groups) do
    show_group_names =
      Enum.map(application.application_show_groups, fn sg ->
        show_groups[sg.show_group_id].group.name
      end)
      |> Enum.join(", ")

    """
    #{user.first_name} #{user.last_name} (#{user.email}) sökte just till följande grupper: #{show_group_names}.
    """
  end
end
