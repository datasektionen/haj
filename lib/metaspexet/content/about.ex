defmodule Metaspexet.Content.About do
  def get_index_data() do
    [
      %{
        title: "Om METAspexet",
        description:
          "METAspexet är ett spex gjord i samarbete mellan Datasektionen och Medieteknik på KTH. Vi består av ett stort antal grupper som tillsammans gör en sak på ett bra sätt och med hjälp av varandra har vi till slut en föreställning att presentera!",
        call_to_action: "Läs mer",
        image: "/images/gruppbild.jpg"
      },
      %{
        title: "Grupperna",
        description:
          "METAspexet har ett helt smörgordsbord av grupper som alla gör olika saker för att få till ett så bra och kul spex tillsammans, läs gärna mer om grupperna för att hitta vilken som passar dig!",
        call_to_action: "Se alla grupper",
        image: "/images/gruppbild.jpg"
      },
      %{
        title: "Spexhistoria",
        description: "METAspexet grundades 2012 och har vuxit storartat under den tiden.",
        call_to_action: "Alla spex",
        image: "/images/gruppbild.jpg"
      }
    ]
  end
end
