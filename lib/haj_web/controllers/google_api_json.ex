defmodule HajWeb.GoogleApiJSON do
  @doc """
  Renders a consent message.
  """
  def consent(_params) do
    %{info: "Consent received with success!"}
  end

  def error(message) do
    %{error: "Something went wrong"}
  end
end
