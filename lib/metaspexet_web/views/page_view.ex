defmodule MetaspexetWeb.PageView do
  use MetaspexetWeb, :view

  def format_time(datetime) do
    day = case DateTime.to_date(datetime) |> Date.day_of_week() do
      5 -> "Fredag"
      6 -> "Lördag"
      7 -> "Söndag"
      _ -> ""
    end

    "#{day} #{datetime.day()} Mars #{DateTime.to_time(datetime) |> Time.to_string() |> String.slice(0..-4)}"
  end
end
