defmodule HajWeb.ApplicationsLive.ApproveComponent do
  use HajWeb, :live_component

  alias Haj.Policy
  alias Haj.Spex

  def update(%{application: app} = assigns, socket) do
    memberships =
      Haj.Spex.get_show_groups_for_user(app.user_id)
      |> Enum.map(fn %{id: id} -> id end)

    {:ok, socket |> assign(assigns) |> assign(memberships: memberships)}
  end

  def handle_event("approve", %{"show_group" => show_group_id}, socket) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    application = socket.assigns.application

    if Policy.authorize?(
         :applications_approve,
         socket.assigns.current_user,
         show_group
       ) do
      if Spex.member_of_show_group?(application.user.id, show_group_id) do
        push_flash(
          :error,
          "#{application.user.full_name} är redan medlem i #{show_group.group.name}."
        )
      else
        case Haj.Spex.create_group_membership(%{
               user_id: application.user.id,
               show_group_id: show_group_id,
               role: :gruppis
             }) do
          {:ok, _} ->
            push_flash(
              :info,
              "#{application.user.full_name} antogs till #{show_group.group.name}."
            )

          {:error, _} ->
            push_flash(:error, "Något gick fel.")
        end
      end
    else
      push_flash(:error, "Du har inte rättigheter att anta till denna grupp.")
    end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Antag <%= @application.user.full_name %>
        <:subtitle>Antag personen till grupper.</:subtitle>
      </.header>

      <.form
        :let={_f}
        for={%{}}
        as={:group}
        phx-submit="approve"
        class="mt-2 flex flex-col gap-2"
        phx-target={@myself}
      >
        <.input
          type="select"
          name="show_group"
          prompt="Välj grupp"
          class="flex-grow"
          value=""
          options={group_options(@application.application_show_groups, @memberships)}
        />

        <div class="flex flex-row justify-end">
          <.button type="submit">
            Antag
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  defp group_options(show_groups, memberships) do
    Enum.reject(show_groups, fn asg -> asg.show_group_id in memberships end)
    |> Enum.map(fn asg -> [key: asg.show_group.group.name, value: asg.show_group.id] end)
  end
end
