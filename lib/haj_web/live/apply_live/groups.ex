defmodule HajWeb.ApplyLive.Groups do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  on_mount {HajWeb.UserAuth, {:ensure_authenticated, "/sok/groups"}}

  alias Haj.Spex
  alias Haj.Applications.ApplicationShowGroup
  alias Haj.Applications

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]

    unfilled? =
      Enum.any?([:email, :class, :phone], fn val ->
        val = Map.get(user, val)
        val == nil || val == ""
      end)

    case unfilled? do
      true ->
        {:ok,
         socket
         |> put_flash(:error, "Du måste fylla i dina uppgifter först!")
         |> push_navigate(to: ~p"/sok/edit")}

      false ->
        current_spex = Spex.current_spex()

        {application, pre_filled?} =
          case Haj.Applications.get_current_application_for_user(user.id) do
            nil -> {%Haj.Applications.Application{}, false}
            app -> {app, true}
          end

        groups =
          Spex.get_show_groups_for_show(current_spex.id)
          |> Enum.filter(fn %{application_open: o} -> o end)


        socket =
          if pre_filled? do
            put_flash(
              socket,
              :info,
              "Data fylld från tidigare ansökan. Du kan uppdatera den genom att fylla i nya uppfiter."
            )
          else
            socket
          end

        changeset = Haj.Applications.change_application(application)

        {:ok,
         assign(socket,
           groups: groups,
           application: application,
           page_title: "Sök grupper",
           pre_filled: pre_filled?
         )
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
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

  @impl true
  def handle_event("validate", %{"application" => %{"application_show_groups" => apps}}, socket) do
    application_show_groups =
      Enum.filter(apps, fn {_, v} -> v == "true" end)
      |> Enum.map(fn {k, _} -> String.to_integer(k) end)
      |> Enum.reduce([], fn id, acc ->
        [%ApplicationShowGroup{show_group_id: id} | acc]
      end)

    {:noreply,
     assign(socket,
       application: %{
         socket.assigns.application
         | application_show_groups: application_show_groups
       }
     )}
  end

  @impl true
  def handle_event("save", %{"application" => %{"application_show_groups" => apps}}, socket) do
    sgs =
      Enum.filter(apps, fn {_, v} -> v == "true" end)
      |> Enum.map(fn {k, _} -> String.to_integer(k) end)

    cond do
      length(sgs) == 0 ->
        {:noreply, socket |> put_flash(:error, "Du måste söka minst en grupp!")}

      !Applications.open?() ->
        {:noreply, socket |> put_flash(:error, "Ansökan är stängd.") |> redirect(to: ~p"/sok")}

      true ->
        case Applications.create_application(
               socket.assigns.current_user.id,
               Spex.current_spex().id,
               sgs
             ) do
          {:ok, _} ->
            socket =
              if socket.assigns.pre_filled do
                put_flash(
                  socket,
                  :info,
                  "Din ansökan uppdaterades. Glöm inte att genomföra hela ansökan!"
                )
              else
                socket
              end

            {:noreply, socket |> push_navigate(to: ~p"/sok/complete")}

          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Något gick fel!")}
        end
    end
  end

  defp chefer(group) do
    chefs =
      Enum.filter(group.group_memberships, fn u -> u.role == :chef end)
      |> Enum.map(fn chef ->
        "#{chef.user.first_name} #{chef.user.last_name}"
      end)

    case chefs do
      [] -> "Chef saknas"
      [c] -> "Chef: #{c}"
      _ -> "Chefer: " <> Enum.join(chefs, ", ")
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.application_steps class="mt-8" step={3} />

    <div class="mt-16 flex flex-col">
      <h2 class="text-2xl font-semibold">
        Grupper
      </h2>

      <p class="mt-4 text-sm text-gray-500 sm:text-base">
        Här finns alla grupper i spexet med beskrivningar. Klicka i de grupper som du vill söka. Det går alltid att söka flera grupper och gå
        på intervju för att få mer information och sedan bestämma sig.
      </p>

      <.form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        class="mt-6 flex flex-col divide-y divide-gray-200"
      >
        <div :for={sg <- @groups} class="flex flex-row items-center py-4">
          <label class="w-full hover:cursor-pointer">
            <div class="flex flex-row items-center justify-between">
              <div name={sg.id} class="text-xl font-bold">
                <%= sg.group.name %>
              </div>
              <.group_checkbox
                name={"application[application_show_groups][#{sg.id}]"}
                value={applied?(@application, sg)}
              />
            </div>

            <p>
              <%= chefer(sg) %>
            </p>

            <p class="pt-1 text-sm text-gray-600 sm:text-base">
              <span class="whitespace-pre-line"><%= sg.application_description %></span>
            </p>
          </label>
        </div>

        <div class="col-span-6 border-t pt-4 text-right">
          <.button type="submit">
            Nästa
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  defp group_checkbox(%{value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@name}
        name={@name}
        value="true"
        checked={@checked}
        class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
      />
    </div>
    """
  end
end
