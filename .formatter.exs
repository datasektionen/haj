[
  import_deps: [:ecto, :phoenix],
  plugins: [TailwindFormatter.MultiFormatter],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,heex}"],
  subdirectories: ["priv/*/migrations"]
]
