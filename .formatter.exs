[
  import_deps: [:ecto, :phoenix, :let_me, :ecto_sql],
  plugins: [TailwindFormatter.MultiFormatter],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,heex}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [tab: 2]
]
