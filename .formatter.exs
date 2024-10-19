[
  import_deps: [:ecto, :ecto_sql, :phoenix, :let_me],
  plugins: [TailwindFormatter.MultiFormatter],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,heex}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [tab: 2]
]
