defmodule HajWeb.ApplyLive do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, %{"user_token" => token}, socket) do
    user = Haj.Accounts.get_user_by_session_token(token)
    current_spex = Spex.current_spex()

    application =
      case Haj.Applications.get_applications_for_user(user.id)
           |> Enum.filter(fn %{show_id: id} -> id == current_spex.id end) do
        [app | _] -> app
        _ -> nil
      end

    show_groups =
      Spex.get_show_groups_for_show(current_spex.id)
      |> Enum.filter(fn %{application_open: o} -> o end)

    socket =
      assign(socket,
        show_groups: show_groups,
        current_user: user,
        show: current_spex,
        application: application
      )

    socket = case application do
      nil -> socket
      _ -> socket |> put_flash(:info, "Data fylld från tidigare ansökan. Du kan uppdatera den genom att fylla i nya uppfiter.")
    end

    {:ok, socket}
  end

  def handle_event("apply", %{"application" => %{"show_groups" => groups} = application}, socket) do
    case Haj.Accounts.update_user(socket.assigns.current_user, application) do
      {:ok, user} ->

        application =
          Map.put(application, "user_id", user.id)
          |> Map.put("show_groups", selected_groups(groups))
          |> Map.put("show_id", socket.assigns.show.id)

        case Haj.Applications.create_application(application) do
          {:ok, _} ->
            {:noreply, redirect(socket, to: Routes.application_path(socket, :created))}
        end
    end
  end

  defp selected_groups(groups) do
    groups
    |> Enum.reduce([], fn {k, v}, acc ->
      case v do
        "true" -> [String.to_integer(k) | acc]
        "false" -> acc
      end
    end)
  end

  defp applied?(application, show_group) do
    if application do
      Enum.any?(application.application_show_groups, fn %{show_group_id: id} -> id == show_group.id end)
    else
      false
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row md:gap-8 ">
      <div class="md:flex-[1.5]">
        <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mb-2">Beskrivning av grupperna</h1>
        <%= for group <- @show_groups do %>
        <div>
        <h2 class="uppercase font-bold"><%= group.group.name %></h2>
        <h3 class="">Chefer:
        <%= Enum.map(group.group_memberships, fn chef -> "#{chef.user.first_name} #{chef.user.last_name}" end) |> Enum.join(", ") %>
        </h3>
        <%= group.application_description %>
        </div>
        <% end %>
      </div>

      <%= form_for :application, "#", [phx_submit: "apply", class: "flex flex-col gap-1 mb-4 mt-4 md:flex-[1] md:mt-0"], fn f -> %>
      <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mb-2">Användaruppgifter</h1>
      <label>KTH-id:</label>
      <input type="text" value={@current_user.username} class="bg-gray-200" disabled>

      <%= label f, :phone, "Telefonnummer" %>
      <%= text_input f, :phone, required: true, value: @current_user.phone %>

      <%= label f, :class, "Klass (Exempelvis D-20 eller Media-21)" %>
      <%= text_input f, :class, required: true, value: @current_user.class %>
      <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mt-2 mb-2">Vilka grupper vill du söka?</h1>

      <%= inputs_for f, :show_groups, fn gf -> %>
      <%= for sg <- @show_groups do %>
        <div class="flex items-center">
        <%= checkbox gf, "#{sg.id}", value: applied?(@application, sg) %>
        <%= label gf, "#{sg.id}", "#{sg.group.name}", class: "uppercase font-bold px-2" %>
        </div>
      <% end %>
      <% end %>


      <div class="uppercase font-bold border-b-2 border-burgandy text-xl mt-2 mb-2">Övrigt</div>
      <%= label f, :special_text, "Om du har sökt orquestern eller bandet, skriv vilka instrument och/eller vilka stämmor du sjunger!" %>
      <%= textarea f, :special_text, value: @application && @application.special_text %>

      <%= label f, :other, "Har du något övrigt på hjärtat?" %>
      <%= textarea f, :other, value: @application && @application.other %>

      <%= submit "Sök", class: "uppercase font-bold mt-1 text-white bg-burgandy text-lg px-3 py-2 self-start" %>
      <% end %>
    </div>
    """
  end
end
