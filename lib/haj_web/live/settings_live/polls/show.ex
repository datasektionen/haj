defmodule HajWeb.SettingsLive.Poll.Show do
  use HajWeb, :live_view

  alias Haj.Polls
  alias Haj.Polls.Option

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    options = Polls.list_options_for_poll(id)

    {:ok, stream(socket, :options, options)}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:poll, Polls.get_poll!(id))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, action, _params) when action in [:show, :edit] do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:option, nil)
  end

  defp apply_action(socket, :show_option, %{"id" => _id, "option_id" => option_id}) do
    socket
    |> assign(:page_title, "Show Option")
    |> assign(:option, Polls.get_option!(option_id))
  end

  defp apply_action(socket, :edit_option, %{"id" => _id, "option_id" => option_id}) do
    socket
    |> assign(:page_title, "Edit Option")
    |> assign(:option, Polls.get_option!(option_id))
  end

  defp apply_action(socket, :new_option, _params) do
    socket
    |> assign(:page_title, "New Option")
    |> assign(:option, %Option{
      poll_id: socket.assigns.poll.id,
      creator_id: socket.assigns.current_user.id
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Options")
    |> assign(:option, nil)
  end

  @impl true
  def handle_info({HajWeb.OptionLive.FormComponent, {:saved, option}}, socket) do
    {:noreply, stream_insert(socket, :options, option)}
  end

  @impl true
  def handle_event("delete_option", %{"id" => id}, socket) do
    option = Polls.get_option!(id)
    {:ok, _} = Polls.delete_option(option)

    {:noreply, stream_delete(socket, :options, option)}
  end

  defp page_title(:show), do: "Show Poll"
  defp page_title(:edit), do: "Edit Poll"
end
