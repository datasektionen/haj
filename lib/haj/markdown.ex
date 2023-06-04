defmodule Haj.Markdown do
  def to_html!(markdown, options \\ []) do
    {:ok, ast, _} = EarmarkParser.as_ast(markdown, smartypants: true)

    with_ids = Keyword.get(options, :with_ids, false)

    case with_ids do
      true ->
        Earmark.Transform.map_ast_with(ast, 1, &transformer/2, true)

      false ->
        ast
    end
    |> Earmark.Transform.transform()
    |> Earmark.as_html!()
  end

  defp transformer({tag, attrs, _, m}, count) do
    case Regex.match?(~r{h[1-6]}, tag) do
      true ->
        {{tag, Earmark.AstTools.merge_atts(attrs, id: "heading-#{count}"), nil, m}, count + 1}

      false ->
        {{tag, attrs, nil, m}, count}
    end
  end
end
