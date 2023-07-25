defmodule HajWeb.ApplyLive.Groups do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  alias Haj.Accounts

  on_mount {HajWeb.UserAuth, {:ensure_authenticated, "/sok/groups"}}

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
        {:ok, socket}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.application_steps class="mt-8 mt-auto" step={3} />

    <div class="mt-8 flex flex-col">
      <h2 class="text-2xl font-semibold">
        Grupper
      </h2>
      <p class="mt-4 text-sm text-gray-500">
        Genom att fylla i data i här godkänner du att uppgifterna sparas för rekrytering.
        Om du vill veta mer om hur uppgifterna används eller att dina uppgifter ska tas bort kan du höra av dig
        till <a href="mailto:webb@metaspexet.se" class="text-black">webbansvarig</a>.
      </p>
    </div>
    """
  end
end
