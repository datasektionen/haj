defmodule HajWeb.ResponsibilityLive.History do
  use HajWeb, :live_view
  alias Haj.Spex
  alias Haj.Responsibilities

  on_mount {HajWeb.UserAuth, {:authorize, :responsibility_read}}

  @impl true
  def mount(_params, _session, socket) do
    responsibilities = Responsibilities.get_user_responsibilities(socket.assigns.current_user.id)
    current_show = Spex.current_spex()

    {current, prev} =
      Enum.split_with(responsibilities, fn %{show_id: id} -> id == current_show.id end)

    {:ok, assign(socket, current_responsibilities: current, prev_responsibilities: prev)}
  end

  attr :navigate, :any, required: true
  slot :inner_block, required: true

  defp card(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="flex flex-col gap-1 rounded-lg border px-4 py-4 shadow-sm hover:bg-gray-50 sm:gap-1.5"
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
