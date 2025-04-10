defmodule HajWeb.GroupLive.ExtraQuestions do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Repo
  alias Haj.Policy

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)
    changeset = Spex.change_show_group(show_group)

    {:ok,
     socket
     |> assign(show_group: show_group, page_title: show_group.group.name)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"show_group" => show_group_params}, socket) do
    case Spex.update_show_group(socket.assigns.show_group, show_group_params) do
      {:ok, show_group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sparat.")
         |> assign_form(Spex.change_show_group(show_group))}

      {:error, changeset} ->
        {:noreply, socket |> put_flash(:error, "Något gick fel.") |> assign_form(changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="mt-4 text-3xl font-bold">
      Lägg till frågor till <span class="text-burgandy-600"><%= @page_title %></span>
    </h1>
    <.simple_form for={@form} phx-submit="save" class="flex flex-col pb-2">
      <.input
        field={@form[:application_extra_question]}
        label="Extra fråga i ansökan. Om du lämnar detta blankt kommer ingen extra fråga visas."
        type="textarea"
      />
      <.input field={@form[:application_open]} label="Gruppen går att söka" type="checkbox" />

      <:actions>
        <.button phx-disable-with="Sparar..." class="rounded-md px-16">Spara</.button>
      </:actions>
    </.simple_form>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end
end
