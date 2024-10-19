defmodule Haj.Markdown do
  def to_html!(markdown, options \\ []) do
    {:ok, ast, _} = Earmark.Parser.as_ast(markdown, smartypants: true)

    with_ids = Keyword.get(options, :with_ids, false)

    case with_ids do
      true ->
        Earmark.Transform.map_ast_with(ast, {1, %{}}, &transformer/2, true)

      false ->
        ast
    end
    |> Earmark.Transform.transform()
    |> Earmark.as_html!()
  end

  defp transformer({tag, attrs, data, m}, {count, map} = acc) when is_binary(tag) do
    case Regex.match?(~r{h[1-6]}, tag) do
      true ->
        slug = slugify(data)

        # Save a map of counts for each slug to keep track of duplicates
        map = Map.update(map, slug, 0, &(&1 + 1))

        slug = if map[slug] > 0, do: slug <> "-" <> Integer.to_string(map[slug]), else: slug

        {{tag,
          Earmark.AstTools.merge_atts(attrs, [
            {"data-heading-index", "#{count}"},
            id: "#{slug}"
          ]), nil, m}, {count + 1, map}}

      false ->
        {{tag, attrs, nil, m}, acc}
    end
  end

  defp transformer({tag, attrs, _, m}, acc) when is_atom(tag),
    do: {{tag, attrs, nil, m}, acc}

  defp slugify(data) when is_list(data) do
    # From https://github.com/yzhang-gh/vscode-markdown/blob/99f85cf9475d00ed6898ce74bad05128f1efee8f/src/util/slugify.ts#L15
    Enum.join(data, "")
    |> String.replace(~r/[^\p{L}\p{M}\p{Nd}\p{Nl}\p{Pc}\- ]/u, "")
    |> String.downcase()
    |> String.replace(~r/ /, "-")
  end
end
