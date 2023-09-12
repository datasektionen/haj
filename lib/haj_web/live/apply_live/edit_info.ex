defmodule HajWeb.ApplyLive.EditInfo do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  alias Haj.Accounts

  on_mount {HajWeb.UserAuth, {:ensure_authenticated, "/sok/edit"}}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    changeset = Accounts.change_user(user)

    {:ok, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns[:current_user]
      |> Accounts.User.application_changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    changeset =
      socket.assigns[:current_user]
      |> Accounts.User.application_changeset(params)

    case Haj.Repo.update(changeset) do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/sok/groups")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Något gick fel, kolla att allt är ifyllt korrekt.")
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.application_steps class="mt-8" step={2} />

    <div class="mt-16 flex flex-col">
      <h2 class="text-2xl font-semibold">
        Persondata och kontaktuppgifter
      </h2>
      <p class="mt-4 text-sm text-gray-500 sm:text-base">
        Genom att fylla i data i här godkänner du att uppgifterna sparas för rekrytering.
        Om du vill veta mer om hur uppgifterna används eller att dina uppgifter ska tas bort kan du höra av dig
        till <a href="mailto:direqtionen@metaspexet.se" class="text-burgandy-500 font-bold">Direqtionen</a>.
      </p>

      <.form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        class="mt-6 grid grid-cols-6 gap-4 pt-2 md:gap-6"
      >
        <.input
          field={@form[:first_name]}
          type="text"
          label="Förnamn"
          class="col-span-6 sm:col-span-3"
        />
        <.input
          field={@form[:last_name]}
          type="text"
          label="Efternamn"
          class="col-span-6 sm:col-span-3"
        />
        <.input
          field={@form[:username]}
          type="text"
          label="KTH-id"
          class="col-span-6 sm:col-span-2"
          disabled="true"
        />
        <.input field={@form[:email]} type="text" label="Email" class="col-span-6 sm:col-span-4" />
        <.input
          field={@form[:class]}
          type="text"
          label="Årskurs (ex D-20)"
          class="col-span-6 sm:col-span-2"
        />
        <.input
          field={@form[:phone]}
          type="text"
          label="Telefonnummer"
          class="col-span-6 sm:col-span-4"
        />
        <div class="col-span-6 border-t pt-4 text-right">
          <.button type="submit">
            Nästa
          </.button>
        </div>
      </.form>
    </div>
    """
  end
end
