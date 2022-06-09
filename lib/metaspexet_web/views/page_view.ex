defmodule MetaspexetWeb.PageView do
  use MetaspexetWeb, :view

  def card(assigns) do
    ~H"""
    <div class="rounded-sm overflow-hidden opacity-0 md:relative from-black after:bg-gradient-to-t after:overflow-hidden after:invisible after:absolute after:top-0 after:left-0 after:w-full after:h-full after:z-0 md:after:visible xl:after:invisible"
         x-intersect.once="$el.classList.add('fade-in-up')">
      <a class="block rounded-sm overflow-hidden">
        <img src={assigns.card.image}
          class="object-cover ease-in-out duration-500 hover:scale-105 md:hover:scale-100 xl:hover:scale-105">
      </a>
      <div class="flex flex-col md:absolute xl:relative left-0 bottom-0 z-10 md:p-6  md:max-w-xl xl:max-w-none xl:p-0">
        <h1 class="font-title text-3xl pt-4 pb-2 md:text-4xl"><%= assigns.card.title %></h1>
        <p><%= assigns.card.description %></p>
        <a class="flex items-center link-underline mr-auto space-x-2 pt-4 md:pt-6 xl:pt-4">
          <h3 class="font-light uppercase text-xl md:text-2xl"><%= assigns.card.call_to_action %></h3>
          <Heroicons.Solid.arrow_right class="w-4 h-4" />
        </a>
      </div>
    </div>
    """
  end
end
