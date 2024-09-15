defmodule HajWeb.ApplyLive.Complete do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  alias Haj.Spex
  alias Haj.Applications

  on_mount {HajWeb.UserAuth, {:ensure_authenticated, "/sok/edit"}}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    application = Applications.get_pending_application_for_user(user.id)

    if application == nil do
      {:ok,
       socket
       |> put_flash(:error, "Du måste ange vilka grupper du vill söka först.")
       |> push_navigate(to: ~p"/sok/groups")}
    else
      show_groups =
        Applications.get_show_groups_for_application(application.id)
        |> Enum.reduce(%{}, fn sg, acc ->
          Map.put(acc, sg.id, sg)
        end)

      {:ok,
       socket
       |> assign(page_title: "Ansök")
       |> assign(show_groups: show_groups, application: application)
       |> assign_form(Applications.change_application(application))}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  @impl true
  def handle_event("save", %{"application" => application_params}, socket) do
    if Applications.open?() do
      application_params = Map.put(application_params, "status", :submitted)

      case Applications.complete_application(socket.assigns.application, application_params) do
        {:ok, application} ->
          slack_message =
            Haj.Slack.application_message(
              socket.assigns.current_user,
              application,
              socket.assigns.show_groups
            )

          email =
            Applications.application_email(
              socket.assigns.current_user,
              application,
              socket.assigns.show_groups
            )

          Haj.Slack.send_message(Spex.current_spex().slack_webhook_url, slack_message)
          Haj.Applications.send_email(socket.assigns.current_user.email, email)

          {:noreply,
           put_flash(socket, :info, "Ansökan lyckades!")
           |> redirect(to: ~p"/sok/success")}

        {:error, changeset} ->
          {:noreply, put_flash(socket, :error, "Något gick fel.") |> assign_form(changeset)}
      end
    else
      {:noreply, put_flash(socket, :error, "Ansökan är stängd.") |> redirect(to: ~p"/sok")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.application_steps class="mt-8" step={4} />

    <div class="mt-16 flex flex-col">
      <h2 class="text-2xl font-semibold">
        Övriga uppgifter
      </h2>

      <.form for={@form} phx-submit="save" class="mt-2 flex flex-col gap-4 pt-4">
        <.inputs_for :let={asg} field={@form[:application_show_groups]}>
          <.input
            :if={@show_groups[asg.data.show_group_id].application_extra_question != nil}
            type="text"
            field={asg[:special_text]}
            label={"Eftersom du sökt #{@show_groups[asg.data.show_group_id].group.name}: #{@show_groups[asg.data.show_group_id].application_extra_question}"}
          />
        </.inputs_for>

        <.input
          :if={length(Map.keys(@show_groups)) > 1}
          field={@form[:ranking]}
          type="textarea"
          label={"Eftersom du söker flera grupper (#{group_names(@show_groups)}): Rangordna vilka grupper du helst vill vara med i"}
        />

        <.input field={@form[:other]} type="textarea" label="Har du något övrigt på hjärtat?" />

        <div>
          <input
            type="checkbox"
            required
            class="mr-2 rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
          />
          Jag godkänner att de här uppgiferna lagras av METAspexet i syfte för rekrytering enligt GDPR och kommer tas bort efter rekryteringen är färdig, senast 1a Januari 2025.
        </div>

        <div class="col-span-6 border-t pt-4 text-right">
          <.button type="submit">
            Ansök!
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  defp group_names(show_groups) do
    Enum.map(show_groups, fn {_, sg} -> sg.group.name end)
    |> Enum.join(", ")
  end
end
