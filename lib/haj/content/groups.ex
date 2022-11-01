defmodule Haj.Content.Gropus do
  # Todo: fixa tidszoner på rimligt sätt

  @groups [
    %{
      name: "Bygg",
      members: [
        "Adrian Salamon",
        "Klara Sandström",
        "Sam Maltin",
        "Amanda Hallstedt",
        "Alice Norrthon",
        "August Jönsson",
        "Axel Lervik",
        "Max Wippich",
        "Emmy Yin",
        "Carin Bystam",
        "Melvin Jakobsson",
        "Tim Jonsson",
        "Douglas Fischer",
        "Pontus Söderlund",
        "Vanja Grigoriev",
        "Joline Frisk",
        "Malte Blomqvist",
        "Morris Hansing"
      ],
      image: "/images/bygg.jpg",
      description:
        "Byggruppen bygger dekoren till spexet. Vi fixar alltså allt som står på scenen, inklusive kullisser.
         Byggruppen ansvararar tillsammans med Rekvisita för roddning och scenbyten."
    },
    %{
      name: "Chefsgruppen",
      members: [
        "Christian Stjernberg",
        "Anja Studic",
        "Erik Hedlund",
        "Elsa Benzinger",
        "Rej Karlander",
        "Gabriella Dalman",
        "Johan Lam",
        "Tobias Hansson",
        "Jakob Carlsson",
        "Anton Lövström",
        "Harald Olin",
        "Anders Steen",
        "Jessica Gorwat",
        "Kevin Wenström",
        "Saga Jonasson",
        "Martin Lindberg",
        "Adrian Salomon",
        "Julia Wang",
        "Martin Neihoff",
        "Erik Nordmark",
        "Joaquín Bonino Quintana",
        "Jonathan Hedin",
        "Ellen Bäck",
        "Markus Wesslén",
        "Lara Rostami",
        "Klara Sandström",
        "Julia Huang"
      ],
      image: "/images/Chefsgrupp-Tot.jpg",
      description:
        "Chefsgruppen består av alla chefer för övriga grupper samt chefer som är ansvariga för ekonomi och synk.
         Chefsgruppen är ansvariga för gemensamma riktningen och är ansvariga gentemot resten av spexet."
    },
    %{
      name: "SpexM",
      members: [
        "Klara Sandström",
        "My Andersson",
        "Rej Karlander",
        "Adrian Salamon",
        "Tobias Hansson",
        "Oscar Bergström",
        "Eric Sandberg",
        "Filippa Nilsson",
        "Anna Remmare",
        "Ludvig Siljeholm",
        "Isak Lefevre",
        "Amanda Hallstedt"
      ],
      image: "/images/spexm.jpg",
      description:
        "SpexM är METAspexets helt egna klubbmästeri. Vi håller i pubbar och sittningar för spexet, både internt
         för spexare men även vissa event för Data- och Mediasektionerna. Vi ser även till att spexet är mätta och
         belåtna under föreställningarna då vi lagar mat."
    },
    %{
      name: "Arr",
      members: [
        "Anton Lövström",
        "Edit Flores",
        "Harald Olin",
        "Jakob Alfredsson",
        "Tore Nylén",
        "Tobias Bengtsson",
        "Victor Millberg",
        "Philip Berrez"
      ],
      image: "/images/Arr.jpg",
      description:
        "För varje enastående musiknummer som syns på scen så har Arrgruppen arrangerat låtarna
                    för bandet att spela eller för kören och squådis att sjunga."
    },
    %{
      name: "Orquestern",
      members: [
        "Harald Olin",
        "Edit Flores",
        "Gustav Henningsson",
        "Eliott Remmer",
        "Isak Larsson",
        "Jakob Carlsson",
        "Martin Mörsell"
      ],
      image: "/images/Orqester.jpg",
      description:
        "Ett spex är inget spex utan massor av musik, och det är vi i orquestern som spelar musiken, live, under föreställningarna.
                    Vi spelar även på spexpubar när andan faller på."
    },
    %{
      name: "Dans",
      members: [
        "Jessica Gorwat",
        "Bahar Kimanos",
        "Emilia Rosenqvist",
        "Kristin Eriksson",
        "Isabella Gobl"
      ],
      image: "/images/dans.jpg",
      description: "Dansgruppen dansar till och koreograferar spexets musiknummer."
    },
    %{
      name: "Rekvisita",
      members: [
        "Julia Wang",
        "Kei Duke-Bergman",
        "Fabian Andréasson",
        "Tore Forslin",
        "Bahar Kimanos",
        "Kristin Eriksson",
        "Rej Karlander",
        "Meya Wikner"
      ],
      image: "/images/requisita.jpg",
      description:
        "Om du ser någon liten revisita på scen så är det rekvisitagruppen som har konstruerat eller införskaffat."
    },
    %{
      name: "Direqtionen",
      members: ["Christian Stjernberg", "Anja Studic", "Erik Hedlund"],
      image: "/images/Direqtionen.jpg",
      description:
        "Direqteurerna är högsta hönsen ytterst ansvariga för METAspexet. De leder chefsgruppen och
                    ser till hela spexarbetet flyter på bra."
    },
    %{
      name: "Synk & Ekonomi",
      members: [
        "Tobias Hansson",
        "Jakob Carlsson",
        "Anton Lövström",
        "Jonathan Hedin"
      ],
      image: "/images/synk.jpg",
      description:
        "Utan synk skulle spexet aldrig gå ihop. Synkchefer är exempelvis Musikproducent, Scenograf eller Kommunikatör.
                    Ekonomiansvarige är ansvariga för budge, bokföring, fakturor, utbetalningar och allt annat som har med ekonomi att göra."
    },
    %{
      name: "Kören",
      members: [
        "Philip Berrez",
        "Oscar Hansson",
        "Edvin Nordling",
        "Fanny Erkhammar",
        "Vanja Vidmark",
        "Kristin Rosen",
        "Herman Karlsson",
        "Anders Steen"
      ],
      image: "/images/koren.jpg",
      description:
        "Kören är gruppen som står för ljuvlig harmoni och härlig stämning inom spexet. Vi sjunger under musiknummer och
                    spelar statist- och ensembleroller under föreställningarna."
    },
    %{
      name: "Squådis",
      members: [
        "Erik Nordmark",
        "Joaquín Bonino Quintana",
        "Alexander Gemal",
        "Maria Moliteus",
        "Jonathan Hedin",
        "Johan Hamredahl",
        "Victoria Hendered",
        "Axel Barck-Holst",
        "Sara Videfors",
        "Emil Wallgren",
        "Elsa Benzinger",
        "Dante Ardström"
      ],
      image: "/images/skådis.jpg",
      description:
        "Utan squådisgruppen blir det inget spex! Det är squådisar som gestaltar manusets karaktärer och b
                    låser liv i dem för publikens nöje! Har du något att säga till de? Gör ett utrop!"
    },
    %{
      name: "Regi",
      members: ["Erik Nordmark", "Joaquín Bonino Quintana"],
      image: "/images/regi.jpg",
      description: "Regi är ansvariga för att leda squådisgruppen och all regi under spexet."
    },
    %{
      name: "Fotofilm",
      members: [
        "Lara Rostami",
        "Oliver Kamruzzaman",
        "Emilia Rosenqvist",
        "Alice Norrthon",
        "Alex Modeé",
        "Jakob Pettersson",
        "Johan Lam",
        "Julia Huang",
        "Julia Hallberg"
      ],
      image: "/images/fotofilm.jpg",
      description:
        "Fotofilmgruppen dokumenterar spexet från början till slut, genom att fotografera och filma större rep,
                    gruppmöten, pubar och event, och till slut föreställningarna under våren!"
    },
    %{
      name: "Kostym",
      members: [
        "Martin Neihoff",
        "My Andersson",
        "Julia Huang",
        "Vanja Vidmark",
        "Karin de Verdier",
        "Lara Rostami",
        "Bahar Kimanos",
        "Tim Jonsson",
        "Joline Frisk",
        "Albin Haraldsson",
        "Gabriella Dalman",
        "Sara Norman",
        "Sofia Eriksson"
      ],
      image: "/images/kostym.jpg",
      description:
        "Kostymgruppen är den grupp som designar kostymer till spexets olika karaktärer och alla  andra som står på scen.
                    Vi arbetar tillsammans med Sminq och Dekåren för att ta fram och ge liv åt de karaktärer som Manusgruppen skapat."
    },
    %{
      name: "Lyrique",
      members: [
        "Kevin Wenström",
        "Aleks Petkov",
        "Alfred Liljeström",
        "Anna Akopyan",
        "Emil Wallgren",
        "Emil Hultcrantz",
        "Martin Lindberg",
        "Jessica Gorwat",
        "Kei Duke-Bergman",
        "Saga Jonasson"
      ],
      image: "/images/lyrique.jpg",
      description:
        "Lyriquegruppen skriver texterna till spexets många och viktiga musiknummer.
                    Vi skriver nya texter för redan existerande låtar så att de ska passa till spexet."
    },
    %{
      name: "Ljud och Ljus",
      members: [
        "Ellen Bäck",
        "Markus Wesslén",
        "Oskar Malmström",
        "Nora Odelius",
        "Theodor Morfeldt Gadler",
        "Jonas Lundin",
        "David Puustinen",
        "Filip Ramslöv"
      ],
      image: "/images/LOL.jpg",
      description:
        "Det är vi i Ljud- och Ljusgruppen (även kallad LoL) som fixar med det mesta som gäller teknik i spexet.
                    Vi ser till att bandet hörs och sqådis syns, fixar så att det lyser i fina färger, trasslar med sladdar och petar på coola prylar."
    },
    %{
      name: "Manus",
      members: [
        "Martin Lindberg",
        "Saga Jonasson",
        "Joaquin Bonino Quintana",
        "Erik Nordmark",
        "Hampus Huledal",
        "Martin Neihoff",
        "Jakob Carlsson",
        "Hugo Forsman",
        "Fredrik Blomqvist",
        "Love Lindgren",
        "Sandra Reinecke",
        "Morris Hansing",
        "Lukas Mosskull",
        "Anna Akopyan",
        "Kevin Mathewson",
        "Emilia Rosenqvist"
      ],
      image: "/images/manus.jpg",
      description:
        "Vad vore ett spex utan ett manus? Fullständigt kaotiskt, såklart!
                    Manusgruppen är de som ansvarar för att lägga grunden för hela spexet.
                    Vi skriver repliker, brainstormar skämt och ordvitsar samt ser till att spexet följer en fin dramaturgi som publiken kan följa med i."
    },
    %{
      name: "Sminq & Hår",
      members: [
        "Sandra Larsson",
        "Molly Gidfors Haraldsson",
        "Fanny Erkhammar",
        "Viola Söderlund",
        "Julia Huang",
        "August Jönsson",
        "Sandra Reinecke"
      ],
      image: "/images/Smink_Hår.jpg",
      description:
        "Sminq & Hår-gruppen är de som teatersminkar och hårfixar på de som står på scen!
      Sminq planerar också karaktärers smink baserat på karaktärernas personligheter!"
    },
    %{
      name: "Grafik",
      members: [
        "Gabriella Dalman",
        "Rej Karlander",
        "Isadora Winter",
        "Julia Wang",
        "Max Wippich",
        "Emily Nilsson",
        "Julia Hallberg"
      ],
      image: "/images/grafik2.jpg",
      description:
        "Grafikgruppen tar fram allt grafiskt material som behövs för spexet, både internt och externt.
                    Det kan vara allt från märken och merch till posters och programblad eller vad vi är taggade på att göra!"
    },
    %{
      name: "Webb",
      members: [
        "Johan Lam",
        "Adam Sjöberg",
        "David Puustinen",
        "Kristin Mickols",
        "Leonard Lund",
        "Pontus Söderlund",
        "Axel Elmarsson",
        "Love Lindgren",
        "Douglas Fischer"
      ],
      image: "/images/webb.jpg",
      description:
        "Webbgruppen jobbar för att utveckla och förbättra spexets hemsida samt interna system för spexet."
    }
  ]

  def get_groups() do
    @groups |> Enum.sort_by(fn %{name: name} -> name end)
  end

  def get_group_by_name(search) do
    Enum.find(@groups, fn %{name: name} -> name == search end)
  end
end
