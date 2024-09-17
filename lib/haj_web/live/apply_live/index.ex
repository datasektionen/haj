defmodule HajWeb.ApplyLive.Index do
  use HajWeb,
      {:live_view,
       [
         layout: {HajWeb.Layouts, :apply},
         container: {:div, class: "flex h-full flex-col bg-zinc-50"}
       ]}

  @impl true
  def mount(_params, _session, socket) do
    open = Haj.Applications.open?()
    show = Haj.Spex.current_spex()

    {:ok, assign(socket, open: open, show: show, page_title: "Sök")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div :if={!@open} class="flex h-full flex-col justify-between">
      <div class="mt-8 flex flex-col">
        <h2 class="text-3xl font-semibold">
          Ansökan stängd
        </h2>
        <p class="mt-2">
          Tyvärr är ansökan till METAspexet inte öppen just nu. Kika gärna in senare!
        </p>
      </div>
    </div>
    <div :if={@open} class="flex h-full flex-col justify-between">
      <.application_steps class="mt-8" step={1} />

      <div class="mt-16 flex flex-col">
        <h2 class="text-3xl font-semibold lg:text-4xl">
          Sök till <span class="text-burgandy-600">METAspexet <%= @show.year.year %>!</span>
        </h2>
        <div class="mt-4 text-sm text-gray-800 sm:text-base lg:max-w-2xl">
          <p>
            Om du vill söka till METAspexet så har du kommit rätt! METAspexet är ett projekt som
            görs gemensamt av Datasektionen och Sektionen för Medieteknik. Vi brukar varje år
            vara runt 130 glada spexare som tillsammans jobbar för att fixa spexföreställningar
            i Maj. Det finns ett helt smörgåsbord med en massa roliga grupper, och hoppas att
            det finns något för just <span class="text-burgandy-600">dig</span>.
          </p>
          <p class="mt-4">
            För att påbörja din ansökan måste du logga in med ditt KTH-konto, och sedan fylla
            i ansökan. Genom att genomföra ansökan godkänner du att vi sparar dina uppgifter
            enligt GDPR och att uppgifterna tas bort efter att rekryteringen är avslutad.
          </p>

          <p class="mt-4">
            Informationen hanteras i enlighet med Datasektionens <a
              href="https://styrdokument.datasektionen.se/pm/pm_informationshantering"
              class="text-burgandy-500 font-bold"
            >informationshanteringspolicy</a>.
            Om du vill att uppgifterna ska tas bort kan du maila <a
              href="mailto:direqtionen@metaspexet.se"
              class="text-burgandy-500 font-bold"
            >Direqtionen</a>.
          </p>
        </div>
        <div class="mt-8 flex flex-row justify-end lg:justify-start">
          <.button>
            <.link navigate={~p"/sok/edit"}>
              Starta ansökan
            </.link>
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
