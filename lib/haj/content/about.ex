defmodule Haj.Content.About do
  # Todo: fixa tidszoner på rimligt sätt

  def get_shows() do
    [
      %{title: "Premiär", time: ~U"2022-05-21 18:00:00Z", tickets: "#"},
      %{title: "Matiné", time: ~U"2022-05-22 13:00:00Z", tickets: "#"},
      %{title: "Slasque", time: ~U"2022-05-22 18:00:00Z", tickets: "#"}
    ]
  end

  def get_index_data() do
    [
      %{
        title: "Om METAspexet",
        description:
          "METAspexet är ett spex gjord i samarbete mellan Datasektionen och Medieteknik på KTH. Vi består av ett stort antal grupper som tillsammans gör en sak på ett bra sätt och med hjälp av varandra har vi till slut en föreställning att presentera!",
        call_to_action: "Läs mer",
        image: "/images/gruppbild.jpg",
        link: "/about"
      },
      %{
        title: "Grupperna",
        description:
          "METAspexet har ett helt smörgordsbord av grupper som alla gör olika saker för att få till ett så bra och kul spex tillsammans, läs gärna mer om grupperna för att hitta vilken som passar dig!",
        call_to_action: "Se alla grupper",
        image: "/images/gruppbild.jpg",
        link: "/groups"
      },
      %{
        title: "Spexhistoria",
        description: "METAspexet grundades 2012 och har vuxit storartat under den tiden.",
        call_to_action: "Alla spex",
        image: "/images/gruppbild.jpg",
        link: "/previous"
      }
    ]
  end

  def get_previous_spex() do
    spex = [
      %{title: "På löpsedeln", or_title: "Vart tog alla sedlar vägen?", year: 2012, synopsis: ""},
      %{title: "Mordet på Occidentexpressen", or_title: "En mördare på spåren", year: 2013, synopsis: ""},
      %{title: "Se mig Dr. Clock", or_title: nil, year: 2014, synopsis: ""},
      %{title: "Metahaj",or_title: "Lär en metalog att meta och de är meta för livet",year: 2015, synopsis: "Byggnadsingenjörssektionen ska sätta upp spexet “Jurrassic Campus” eller “När studenten kommer till Krita”, men direktören har försvunnit med all budget. Chefsgruppen måste nu snabbt försöka att lösa problemet så att det blir ett spex alls. Personer hamnar i fel grupper och två av skådisarna försöker att sätta käppar i hjulen för det nya stjärnskottet Anna. Ska de lyckas få ihop ett spex?"},
      %{title: "Kiseldalen", or_title: "Det dalar för familjen", year: 2016, synopsis: "Flera tusen år in i framtiden har allting blivit uppfunnet och alla patent ägs av en organisation som kallas “Familjen”. Den aspirerande uppfinnaren Siv Jobsson lyckas en dag uppfinna något nytt. Med hjälp av sina vänner och sin advokat måste hon försöka ta patent på sin uppfinning och krossa familjens monopol på patent. Men hon har mycket emot sig. Förutom familjens advokat finns även demonen Lucifer i bakgrunden och försöker att ställa till oreda så att han själv kan styra världen."},
      %{title: "Scenskräck", or_title: "Skogen är ett kult ställe", year: 2017, synopsis: "Häng med ut till en enslig stuga i skogen, där syskonen Douglas och Alex ska spendera en lugn och stillsam helg med sina vänner. Men allt är inte riktigt som det verkar… Mystiska saker försiggår i skogen, eller är det bara någon som försöker spela dem ett spratt?"},
      %{title: "Boston Tea Party", or_title: "Ett skepp kommer vaskat", year: 2018, synopsis: "En kall decemberdag 1773 möts Lena Svensson, teälskare extraordinaire och Bostonit… well, ganska ordinaire, av en hemsk syn när hon kommer till jobbet. Inte ett blad te finns att uppbringa i hela staden, och hur kan Lena klara av sin irriterande chef utan en lugnande kopp te (eller elva)?

      METAspexet berättar historian om hur omständigheter utöver det vanliga fick en grå administratör att gå utanför sin komfortzon och tända en revolutionens flamma som skulle spridas (nordväst-)världen över. Hennes jakt efter det blaskiga guldet får hennes väg att korsa en grupp idealistiska rebeller och deras målmedvetne ledare, och tillsammans tar de kampen mot det Engelska imperiets mäktiga representant och hennes lakejer."},
      %{title: "Elementärt", or_title: "Från skrivbord till herrgårdsmord", year: 2019, synopsis: "Arthur Conan Doyle, författare till böckerna om Sherlock Holmes, är ett riktigt dumpucko. Dock skriver han böcker som alla älskar, vilket gör att han är rik och kan bo ett bekvämt liv med sin fru. Men när han får besök av Mortimer Darlington och får uppdraget att lösa det mystiska mordfallet på hans bror bli han så illa tvungen att använda de få hjärnceller han har för att lista ut vem den skyldige är."},
      %{title: "Hjältarnas stad", or_title: "Med stort ansvar kommer tajta trikåer", year: 2020, synopsis: "Detta spex spelades aldrig upp på grund av Coronapandemin."},
      %{title: "Kanal Radikal", or_title: "TV-Stjärnornas Krig", year: 2021, synopsis: "På en TV-studio någonstans i Sverige gnabbas de två TV-personligheterna Gordon och Frida om livet på studion. Efter många år av sjunkande tittarsiffror så behöver de en skjuts uppåt, annars riskerar studion att falla i bitar – bokstavligen. Detta visar sig dock vara svårare än de tror med en inkapabel chef, koffein-injicerad producent och rent ut sagt skitprogram. Då dyker företagsmagnaten Melinda Moneybags upp med ett förslag, men har hon verkligen studions bästa i åtanke?"},
      %{title: "På västfrontet intet spex", or_title: "Andra sidan är ni klara?", year: 2022, synopsis: "Ett världsomspännande krig. Två sidor. Miljontals liv på spel. Genom en stor del av Frankrike, Tyskland och Belgien har Västfronten bildats, ett dödläge av arméer som försöker att avancera in mot varandra men till ingen nytta. På en liten del av fronten finner vi soldater från bägge sidor som börjar tröttna på kriget och den fruktansvärda tillvaro de befinner sig i. Samtidigt håller generaler för bägge sidor på att mynta nya planer för hur de ska ta kriget till nästa nivå. Allt ställs på sin spets när ett knallrött plan kraschlandar i ingenmanslandet mellan de två sidornas läger. Vem är överlevaren och vad bär han på för avgörande information?"}
    ]

    Enum.sort_by(spex, fn %{year: year} -> year end, :desc)
  end
end
