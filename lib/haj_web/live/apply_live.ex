defmodule HajWeb.ApplyLive do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, %{"user_token" => token}, socket) do
    user = Haj.Accounts.get_user_by_session_token(token)
    current_spex = Spex.current_spex()

    {application, pre_filled} =
      case Haj.Applications.get_applications_for_user(user.id)
           |> Enum.filter(fn %{show_id: id} -> id == current_spex.id end) do
        [app | _] -> {app, true}
        _ -> {%Haj.Applications.Application{}, false}
      end

    show_groups =
      Spex.get_show_groups_for_show(current_spex.id)
      |> Enum.filter(fn %{application_open: o} -> o end)

    socket =
      assign(socket,
        show_groups: show_groups,
        current_user: user,
        user: %{phone: user.phone || nil, class: user.class || nil},
        show: current_spex,
        application: application |> Map.put(:extra_text, %{})
      )

    socket =
      case pre_filled do
        false -> socket
        true -> put_flash(socket, :info, "Data fylld från tidigare ansökan. Du kan
                                       uppdatera den genom att fylla i nya uppfiter.")
      end

    {:ok, socket}
  end

  def handle_event("apply", %{"application" => %{"show_groups" => groups} = application}, socket) do
    if application_open?(socket.assigns.show) do
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

          slack_message = application_message(user, application, socket.assigns.show_groups)

          with {:ok, _} <- Haj.Applications.create_application(application),
               _ <- Haj.Slack.send_message(socket.assigns.show.slack_webhook_url, slack_message) do
            {:noreply, redirect(socket, to: Routes.apply_path(socket, :created))}
          end
      end
    else
      {:noreply, redirect(socket, to: Routes.apply_path(socket, :index))}
    end
  end

  def handle_event("toggle_check", %{"application" => %{"show_groups" => sgs}}, socket) do
    alias Haj.Applications.ApplicationShowGroup

    index = Map.keys(sgs) |> hd()

    application_show_groups =
      case socket.assigns.application.application_show_groups do
        app when is_list(app) -> app
        _ -> []
      end

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

  def handle_event("update_form", %{"application" => %{"phone" => val}}, socket) do
    {:noreply, assign(socket, user: %{socket.assigns.user | phone: val})}
  end

  def handle_event("update_form", %{"application" => %{"class" => val}}, socket) do
    {:noreply, assign(socket, user: %{socket.assigns.user | class: val})}
  end

  def handle_event("update_form", %{"application" => %{"other" => val}}, socket) do
    {:noreply, assign(socket, application: %{socket.assigns.application | other: val})}
  end

  def handle_event("update_form", %{"application" => %{"ranking" => val}}, socket) do
    {:noreply, assign(socket, application: %{socket.assigns.application | ranking: val})}
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
    case application.application_show_groups do
      show_groups when is_list(show_groups) ->
        Enum.any?(application.application_show_groups, fn %{show_group_id: id} ->
          id == show_group.id
        end)

      _ ->
        false
    end
  end

  defp chefer(group) do
    Enum.filter(group.group_memberships, fn u -> u.role == :chef end)
    |> Enum.map(fn chef ->
      "#{chef.user.first_name} #{chef.user.last_name}"
    end)
    |> Enum.join(", ")
  end

  defp application_message(user, %{"show_groups" => selected_show_groups}, show_groups) do
    groups =
      Enum.map(selected_show_groups, fn %{id: id} ->
        %{group: %{name: name}} = Enum.find(show_groups, fn %{id: sg_id} -> id == sg_id end)
        name
      end)
      |> Enum.join(", ")

    "#{user.first_name} #{user.last_name} (#{user.email}) sökte just till följande grupper: #{groups}"
  end

  defp application_open?(show) do
    current_date = DateTime.now!("Etc/UTC")

    case show.application_opens && DateTime.compare(show.application_opens, current_date) do
      :lt ->
        case DateTime.compare(show.application_closes, current_date) do
          :gt -> true
          _ -> false
        end

      _ ->
        false
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col mb-8 md:flex-row md:gap-8 ">
      <div class="md:flex-[1.5]" x-data="{expanded: false}">
        <h1 class="uppercase font-bold border-b-2 border-burgandy-500 text-xl mb-2">
          Beskrivning av grupperna
        </h1>
        <div
          class="relative space-y-2"
          x-bind:class="{'after:h-20': !expanded, 'after:h-0' : expanded}"
        >
          <%= for group <- @show_groups do %>
            <div>
              <h2 class="uppercase font-bold"><%= group.group.name %></h2>
              <h3 class="">
                Chefer: <%= chefer(group) %>
              </h3>
              <div class="font-sm whitespace-pre-line"><%= group.application_description %></div>
            </div>
          <% end %>
        </div>
      </div>

      <.form
        :let={f}
        for={:application}
        phx-submit="apply"
        class="flex flex-col gap-1 mt-4 md:flex-[1] md:mt-0"
      >
        <h1 class="uppercase font-bold border-b-2 border-burgandy-500 text-xl mb-2">Användaruppgifter</h1>
        <label>KTH-id:</label>
        <input type="text" value={"#{@current_user.username}@kth.se"} class="bg-gray-200" disabled />

        <%= label(f, :phone, "Telefonnummer") %>
        <%= text_input(f, :phone,
          required: true,
          value: @user.phone,
          phx_change: "update_form",
          phx_debounce: "1000"
        ) %>

        <%= label(f, :class, "Klass (Exempelvis D-20 eller Media-21)") %>
        <%= text_input(f, :class,
          required: true,
          value: @user.class,
          phx_change: "update_form",
          phx_debounce: "1000"
        ) %>
        <%= error_tag(f, :class) %>
        <h1 class="uppercase font-bold border-b-2 border-burgandy-500 text-xl mt-2 mb-2">
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

        <div class="uppercase font-bold border-b-2 border-burgandy-500 text-xl mt-2 mb-2">Övrigt</div>

        <%= if @show_groups |> Enum.filter(fn x -> applied?(@application, x) end) |> length() > 1 do %>
          <%= label(
            f,
            :ranking,
            "Eftersom du söker flera grupper: Rangordna vilka grupper du helst vill vara med i"
          ) %>
          <%= textarea(f, :ranking,
            value: @application && @application.ranking,
            phx_change: "update_form",
            phx_debounce: "1000"
          ) %>
        <% end %>

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
                phx_debounce: "1000",
                value: Map.get(@application.extra_text, "#{sg.id}")
              ) %>
            </div>
          <% end %>
        <% end %>

        <%= label(f, :other, "Har du något övrigt på hjärtat?") %>
        <%= textarea(f, :other,
          value: @application && @application.other,
          phx_change: "update_form",
          phx_debounce: "1000"
        ) %>

        <div>
          <input type="checkbox" required class="mr-1" />
          Jag godkänner att de här uppgiferna lagras av METAspexet i syfte för rekrytering enligt GDPR och kommer tas bort efter rekryteringen är färdig, senast 1a Januari 2023.
        </div>
        <div>
          Informationen hanteras i enlighet med Datasektionens <a
            href="https://styrdokument.datasektionen.se/informationshanteringspolicy"
            class="font-bold text-burgandy-500"
          >informationshanteringspolicy</a>.
          Om du vill att uppgifterna ska tas bort kan du maila <a
            href="mailto:direqtionen@metaspexet.se"
            class="font-bold text-burgandy-500"
          >Direqtionen</a>.
        </div>
        <%= submit("Sök",
          class: "uppercase font-bold mt-1 text-white bg-burgandy-500 text-lg px-3 py-2 self-start"
        ) %>
      </.form>
    </div>
    """
  end
end
