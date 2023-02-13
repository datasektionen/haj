defmodule Haj.Markdown do
  def to_html!(markdown) do
    markdown
    |> Earmark.as_html!(smartypants: true)
    |> HtmlSanitizeEx.html5()
    |> h3_is_max()
    |> dbg()
  end

  def h3_is_max(text) do
    text = Regex.replace(~r{<h1[^<]*>(.*?)<\/h1>}s, text, "<h3>\\1</h3>")
    Regex.replace(~r{<h2[^<]*>(.*?)<\/h2>}s, text, "<h3>\\1</h3>")
  end
end
