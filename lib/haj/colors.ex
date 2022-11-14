defmodule Haj.Colors.RGB do
  defstruct red: 0, blue: 0, green: 0
end

defmodule Haj.Colors do
  alias Haj.Colors.RGB

  @hex_to_dec_symbols %{
    "0" => 0,
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 10,
    "B" => 11,
    "C" => 12,
    "D" => 13,
    "E" => 14,
    "F" => 15
  }

  def hex_to_rgb(<<"#", hex::binary>>) do
    hex_to_rgb(hex)
  end

  def hex_to_rgb(<<hex_red::binary-size(2), hex_green::binary-size(2), hex_blue::binary-size(2)>>) do
    %RGB{
      red: hex_to_decimal(hex_red),
      blue: hex_to_decimal(hex_blue),
      green: hex_to_decimal(hex_green)
    }
  end

  def hex_to_decimal(hex) do
    hex
    |> String.upcase()
    |> String.codepoints()
    |> Enum.map(fn char -> @hex_to_dec_symbols[char] end)
    |> Enum.with_index()
    |> Enum.map(fn {digit, index} -> digit * :math.pow(16,index) end)
    |> Enum.sum()
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
    if c <= 0.03928 do
      c / 12.92
    else
     :math.pow((c + 0.055) / 1.055, 2.4)
    end
  end
end
