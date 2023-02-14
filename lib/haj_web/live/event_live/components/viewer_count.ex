defmodule Haj.Live.ReaderCount do
  use Phoenix.LiveView

  @moduledoc """
    A small LiveView that shows the number of readers of a post using Phoenix Presence
  """

  def render(assigns) do

  end

  def mount(_session, socket) do
    {:ok, assign(socket, :online_count, 0)}
  end
end
