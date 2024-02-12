defmodule HajWeb.UserSettingsLive do
  use HajWeb, :live_view

  alias Haj.Accounts
  alias Haj.Foods
  alias HajWeb.Endpoint

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user] |> Accounts.preload(:foods)

    food_options = Foods.list_foods()
    changeset = Accounts.change_user(user)

    {:ok,
     assign(socket,
       page_title: "Dina uppgifter",
       changeset: changeset,
       food_options: food_options,
       checked_foods: user.foods
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    foods = Foods.list_foods_with_ids(params["foods"] || [])

    changeset =
      %Accounts.User{}
      |> Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset, checked_foods: foods)}
  end

  def handle_event("save", %{"user" => params}, socket) do
    user = socket.assigns[:current_user] |> Haj.Repo.preload(:foods)
    foods = Foods.list_foods_with_ids(params["foods"] || [])

    changeset =
      Accounts.change_user(user, params)
      |> Ecto.Changeset.validate_change(:username, fn :username, _ ->
        [username: "Du kan inte ändra KTH-id!"]
      end)
      |> Ecto.Changeset.put_assoc(:foods, foods)

    case Haj.Repo.update(changeset) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ändringen sparades.")
         |> push_redirect(to: Routes.user_path(Endpoint, :index, user.username))}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = socket |> put_flash(:error, "Något gick fel, kolla att allt är ifyllt korrekt.")
        {:noreply, assign(socket, changeset: changeset, checked_foods: foods)}
    end
  end

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@changeset}
      phx-change="validate"
      phx-submit="save"
      class="grid grid-cols-6 gap-4 md:gap-6"
    >
      <div class="col-span-6">
        <h2 class="text-2xl font-bold">Dina uppgifter</h2>
        <p class="mt-2 text-sm text-gray-500">
          Genom att fylla i data i här godkänner du att uppgifterna sparas för användning i spexsyfte.
          Om du vill veta mer om hur uppgifterna används eller att dina uppgifter ska tas bort kan du höra av dig
          till <a href="mailto:webb@metaspexet.se">webbansvarig</a>.
        </p>
      </div>

      <div class="col-span-6 border-t pt-4 text-lg font-bold">
        Personuppgifter
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:first_name} text="Förnamn" />
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:last_name} text="Efternamn" />
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:class} text="Årskurs (eg D-20 eller Media-21)" />
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:personal_number} text="Personummer" />
        <p class="mt-2 text-sm text-gray-500">
          Detta är endast synligt för administratörer och samlas då uppgifterna
          behövs för att få pengar från ABF.
        </p>
      </div>

      <div class="col-span-6 border-t pt-4 text-lg font-bold">
        Konton och kontakt
      </div>

      <div class="col-span-6 sm:col-span-2">
        <%= label(f, :username, "KTH-id", class: "block text-sm font-medium text-gray-700") %>
        <%= text_input(f, :username,
          class: "mt-1 block w-full rounded-md border-gray-300 bg-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
          disabled: true
        ) %>

        <%= hidden_input(f, :username) %>
        <%= error_tag(f, :username, class: "pt-1 text-sm") %>
      </div>

      <div class="col-span-6 sm:col-span-4">
        <.form_text_input for={f} input={:phone} text="Telefonnummer" />
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:email} text="Email" />
      </div>

      <div class="col-span-6 sm:col-span-3">
        <.form_text_input for={f} input={:google_account} text="Google-konto" />
      </div>

      <div class="col-span-6 border-t pt-4 text-lg font-bold">
        Matpreferenser
      </div>

      <div class="col-span-6">
        <%= label(f, :foods, "Matpreferenser, klicka i alla som stämmer.",
          class: "block text-sm font-medium text-gray-700"
        ) %>
        <div class="mt-2 flex flex-col gap-1 sm:flex-row sm:gap-6">
          <%= for food <- @food_options do %>
            <label class="flex flex-row items-center gap-2">
              <input
                name="user[foods][]"
                type="checkbox"
                value={food.id}
                checked={Enum.member?(@checked_foods, food)}
                class="text-burgandy-600 h-4 w-4 rounded border-gray-300 focus:ring-burgandy-500"
              />
              <%= food.name %>
            </label>
          <% end %>
        </div>
      </div>

      <div class="col-span-6 md:col-span-4">
        <.form_text_input
          for={f}
          input={:food_preference_other}
          text="Övriga matpreferenser eller mer detaljer. Om du inte har några preferenser, lämna blankt."
        />
      </div>

      <div class="col-span-6 border-t pt-4">
        <h3 class="text-lg font-bold">
          Adressuppgifter
        </h3>
        <p class="mt-1 text-sm text-gray-600">
          Dessa uppgifter är endast synliga för administratörer och samlas då uppgifterna
          behövs för att få pengar från ABF.
        </p>
      </div>

      <div class="col-span-6 md:col-span-2">
        <.form_text_input for={f} input={:street} text="Adress" />
      </div>

      <div class="col-span-6 sm:col-span-3 md:col-span-2">
        <.form_text_input for={f} input={:zip} text="Postnummer" />
      </div>

      <div class="col-span-6 sm:col-span-3 md:col-span-2">
        <.form_text_input for={f} input={:city} text="Ort" />
      </div>

      <div class="col-span-6 border-t pt-4 text-right">
        <%= submit("Spara",
          class: "bg-burgandy-500 inline-flex justify-center rounded-md border border-transparent px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-burgandy-600 focus:ring-burgandy-500 focus:outline-none focus:ring-2 focus:ring-offset-2"
        ) %>
      </div>
    </.form>
    """
  end

  defp form_text_input(assigns) do
    ~H"""
    <%= label(
      @for,
      @input,
      @text,
      class: "block text-sm font-medium text-gray-700"
    ) %>
    <%= text_input(
      @for,
      @input,
      class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
    ) %>
    <%= error_tag(@for, @input, class: "pt-1 text-sm") %>
    """
  end
end
