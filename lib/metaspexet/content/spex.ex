defmodule Metaspexet.Content.Spex do
  # Todo: fixa tidszoner på rimligt sätt
  def get_shows() do
    [
      %{title: "Premiär", time: ~U"2022-05-21 18:00:00Z", tickets: "#"},
      %{title: "Matiné", time: ~U"2022-05-22 13:00:00Z", tickets: "#"},
      %{title: "Slasque", time: ~U"2022-05-22 18:00:00Z", tickets: "#"}
    ]
  end
end
