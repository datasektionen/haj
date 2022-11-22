defmodule Haj.Colors.RGB do
  defstruct red: 0, blue: 0, green: 0
end

defmodule Haj.Colors do
  alias Haj.Colors.RGB
  def hex_to_rgb(<<"#", hex::binary>>) do
    hex_to_rgb(hex)
  end

  def hex_to_rgb(<<hex_red::binary-size(2), hex_green::binary-size(2), hex_blue::binary-size(2)>>) do
    %RGB{
      red: Integer.parse(hex_red, 16) |> elem(0),
      blue: Integer.parse(hex_blue, 16) |> elem(0),
      green: Integer.parse(hex_green, 16) |> elem(0),
    }
  end

  @spec pick_text_color(nonempty_binary) :: <<_::56>>
  def pick_text_color(hex_color) do
    rgb = hex_to_rgb(hex_color)
    rgb_c = %RGB{
      red: get_modified_rgb(rgb.red),
      green: get_modified_rgb(rgb.green),
      blue: get_modified_rgb(rgb.blue),
    }
    # Calculate luminance
    luminance = 0.2126 * rgb_c.red + 0.7152 * rgb_c.green + 0.0722 * rgb_c.blue
    if luminance > 0.179 do
      "#000000"
    else
      "#ffffff"
    end
  end

  def get_modified_rgb(c) do
    c = c / 255.0
    if c <= 0.04045 do
      c / 12.92
    else
     :math.pow((c + 0.055) / 1.055, 2.4)
    end
  end
end
