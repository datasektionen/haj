defmodule Haj.Content.Gropus do
  # Todo: fixa tidszoner på rimligt sätt

  @groups [
    %{
      name: "Bygg",
      members: [
        "Adrian Salamon",
        "Melvin Jakobsson",
        "Morris Hansing",
        "Klara Sandström",
        "Joline Frisk",
        "Max Wippich",
        "Tim Jonsson"
      ],
      image: "/images/bygg.png",
      description:
        "Byggruppen bygger dekoren till spexet. Vi fixar alltså allt som står på scenen, inklusive kullisser.
         Byggruppen träffas varje onsdag och bygger i Dekis, som vi delar med alla andra spex på KTH.
         Bygg är något för dig som är kreativ och gillar att komma på och bygga tokiga ideer."
    },
    %{
      name: "Chefsgruppen",
      members: ["Adrian Salamon", "blah blah blah"],
      image: "/images/Chefsgrupp-Tot.png",
      description: "Chefsgruppen är den näst bästa gruppeeeen"
    },
    %{
      name: "SpexM",
      members: ["Adrian Salamon", "blah blah blah"],
      image: "/images/spexm.png",
      description: "SpexM är mkt kärlek <3"
    },
    %{name: "Arr", members: [""], image: "/images/Arr.png", description: "Woooow arr"},
    %{
      name: "Orquestern",
      members: [""],
      image: "/images/Orqester.png",
      description: "Spelar musik under föreställningarna och eventuellt nån spexpub också"
    },
    %{
      name: "Dans",
      members: [""],
      image: "/images/dans.png",
      description: "Dansar under föreställningar och agerar även ibland statister"
    },
    %{
      name: "Requisita",
      members: [""],
      image: "/images/requisita.png",
      description: "Hörde jag picknick-TB?"
    },
    %{
      name: "Dirrarna",
      members: [""],
      image: "/images/Direqtionen.png",
      description: "Oj vilken grej"
    },
    %{
      name: "Synk & Ekonomi",
      members: [""],
      image: "/images/synk.png",
      description: "Cash cash baby"
    },
    %{name: "Kören", members: [""], image: "/images/koren.png", description: "Korven?"},
    %{name: "Squådis", members: [""], image: "/images/skådis.png", description: "På skånska!"},
    %{name: "Regi", members: [""], image: "/images/regi.png", description: "Stand-in-squodisar"},
    %{name: "Fotofilm", members: [""], image: "/images/fotofilm.png", description: "Say cheese!"},
    %{
      name: "Kostym",
      members: [""],
      image: "/images/kostym.png",
      description: "Vilka kostymnissar"
    },
    %{
      name: "Lyrique",
      members: [""],
      image: "/images/lyrique.png",
      description: "Jag är helt lyrisk över låttexterna"
    },
    %{
      name: "Ljud och Ljus",
      members: [""],
      image: "/images/LOL.png",
      description: "Spexets mest ljusstarka och högljudda grupp"
    },
    %{
      name: "Manus",
      members: [""],
      image: "/images/manus.png",
      description: "Shakespeares' got nothing on them"
    },
    %{
      name: "Sminq",
      members: [""],
      image: "/images/Smink_Hår.png",
      description: "Snyggaste gruppen"
    },
    %{
      name: "Grafik",
      members: [""],
      image: "/images/grafik2.png",
      description: "Graphic design is my passion"
    },
    %{
      name: "Webb",
      members: [""],
      image: "/images/webb.png",
      description: "De som borde gjort den här hemsidan"
    }
  ]

  def get_groups() do
    @groups
  end

  def get_group_by_name(search) do
    Enum.find(@groups, fn %{name: name} -> name == search end)
  end
end
