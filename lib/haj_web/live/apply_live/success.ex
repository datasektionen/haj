defmodule HajWeb.ApplyLive.Success do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  alias Haj.Applications

  on_mount {HajWeb.UserAuth, {:ensure_authenticated, "/sok/edit"}}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    application = Applications.get_current_application_for_user(user.id)

    if application == nil do
      {:ok,
       socket
       |> put_flash(:error, "Du har inte sökt till METAspexet.")
       |> push_navigate(to: ~p"/sok")}
    else
      show_groups =
        Applications.get_show_groups_for_application(application.id)

      {:ok,
       socket
       |> assign(application: application, show_groups: show_groups)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-16 flex flex-col">
      <h2 class="text-2xl font-semibold">
        Tack för din ansökan!
      </h2>
      <div class="lg:max-w-2xl">
        <div class="pt-4">
          Din ansökan lyckades! 🎉 Du har sökt till följande grupper:
        </div>
        <ul class="my-2 list-inside list-disc">
          <li :for={sg <- @show_groups}>
            <%= sg.group.name %>
          </li>
        </ul>
        <span>
          Du kommer inom kort bli kontaktad av chefer till respektive grupp du sökt! Om du har några frågor så kan du alltid höra av dig till <a
            href="mailto:direqtionen@metaspexet.se"
            class="text-burgandy-500 font-bold"
          >Direqtionen</a>.
        </span>
      </div>
    </div>
    """
  end
end
