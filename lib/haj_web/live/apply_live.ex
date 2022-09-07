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
      |> Map.put(:extra_text, %{})

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

    socket =
      case application do
        nil ->
          socket

        _ ->
          socket
          |> put_flash(
            :info,
            "Data fylld från tidigare ansökan. Du kan uppdatera den genom att fylla i nya uppfiter."
          )
      end

    {:ok, socket}
  end

  def handle_event("apply", %{"application" => %{"show_groups" => groups} = application}, socket) do
    case Haj.Accounts.update_user(socket.assigns.current_user, application) do
      {:ok, user} ->
        extra_text =
          case application do
            %{"extra_text" => extra_text} -> extra_text
            _ -> %{}
          end

        application =
          Map.put(application, "user_id", user.id)
          |> Map.put("show_groups", selected_groups(groups, extra_text))
          |> Map.put("show_id", socket.assigns.show.id)

        case Haj.Applications.create_application(application) do
          {:ok, _} ->
            {:noreply, redirect(socket, to: Routes.apply_path(socket, :created))}
        end
    end
  end

  def handle_event("toggle_check", %{"application" => %{"show_groups" => sgs}}, socket) do
    alias Haj.Applications.ApplicationShowGroup

    index = Map.keys(sgs) |> hd()
    application_show_groups = socket.assigns.application.application_show_groups

    application_show_groups =
      case Map.get(sgs, index) do
        "true" ->
          [
            %ApplicationShowGroup{show_group_id: String.to_integer(index)}
            | application_show_groups
          ]

        "false" ->
          Enum.filter(application_show_groups, fn %{show_group_id: id} ->
            id != String.to_integer(index)
          end)
      end

    {:noreply,
     assign(socket,
       application: %{
         socket.assigns.application
         | application_show_groups: application_show_groups
       }
     )}
  end

  def handle_event("update_text", %{"application" => %{"extra_text" => extra_text}}, socket) do
    {:noreply,
     assign(socket,
       application: %{
         socket.assigns.application
         | extra_text: Map.merge(socket.assigns.application.extra_text, extra_text)
       }
     )}
  end

  defp selected_groups(groups, extra_text) do
    groups
    |> Enum.reduce([], fn {k, v}, acc ->
      case v do
        "true" -> [%{id: String.to_integer(k), special_text: Map.get(extra_text, k)} | acc]
        "false" -> acc
      end
    end)
  end

  defp applied?(application, show_group) do
    if application do
      Enum.any?(application.application_show_groups, fn %{show_group_id: id} ->
        id == show_group.id
      end)
    else
      false
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row md:gap-8 ">
      <div class="md:flex-[1.5]">
        <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mb-2">
          Beskrivning av grupperna
        </h1>
        <%= for group <- @show_groups do %>
          <div>
            <h2 class="uppercase font-bold"><%= group.group.name %></h2>
            <h3 class="">
              Chefer: <%= Enum.map(group.group_memberships, fn chef ->
                "#{chef.user.first_name} #{chef.user.last_name}"
              end)
              |> Enum.join(", ") %>
            </h3>
            <%= group.application_description %>
          </div>
        <% end %>
      </div>

      <%= form_for :application, "#", [phx_submit: "apply", class: "flex flex-col gap-1 mb-4 mt-4 md:flex-[1] md:mt-0"], fn f -> %>
        <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mb-2">Användaruppgifter</h1>
        <label>KTH-id:</label>
        <input type="text" value={"#{@current_user.username}@kth.se"} class="bg-gray-200" disabled />

        <%= label(f, :phone, "Telefonnummer") %>
        <%= text_input(f, :phone, required: true, value: @current_user.phone) %>

        <%= label(f, :class, "Klass (Exempelvis D-20 eller Media-21)") %>
        <%= text_input(f, :class, required: true, value: @current_user.class) %>
        <h1 class="uppercase font-bold border-b-2 border-burgandy text-xl mt-2 mb-2">
          Vilka grupper vill du söka?
        </h1>

        <%= inputs_for f, :show_groups, fn gf -> %>
          <%= for sg <- @show_groups do %>
            <div class="flex items-center">
              <%= checkbox(gf, "#{sg.id}",
                value: applied?(@application, sg),
                phx_change: "toggle_check"
              ) %>
              <%= label(gf, "#{sg.id}", "#{sg.group.name}", class: "uppercase font-bold px-2") %>
            </div>
          <% end %>
        <% end %>

        <div class="uppercase font-bold border-b-2 border-burgandy text-xl mt-2 mb-2">Övrigt</div>

        <%= inputs_for f, :extra_text, fn gf -> %>
          <%= for sg <- @show_groups |> Enum.filter(fn x -> applied?(@application, x) && x.application_extra_question end) do %>
            <div class="flex flex-col">
              <%= label(
                gf,
                "#{sg.id}",
                "Eftersom du söker #{sg.group.name}: #{sg.application_extra_question}"
              ) %>
              <%= textarea(gf, "#{sg.id}",
                phx_change: "update_text",
                value: Map.get(@application.extra_text, "#{sg.id}")
              ) %>
            </div>
          <% end %>
        <% end %>

        <%= label(f, :other, "Har du något övrigt på hjärtat?") %>
        <%= textarea(f, :other, value: @application && @application.other) %>

        <%= submit("Sök",
          class: "uppercase font-bold mt-1 text-white bg-burgandy text-lg px-3 py-2 self-start"
        ) %>
      <% end %>
    </div>
    """
  end
end
