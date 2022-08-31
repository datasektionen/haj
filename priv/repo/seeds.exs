# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Haj.Repo.insert!(%Haj.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Haj.Repo.insert!(%Haj.Spex.Show{
  description: "Coolt spex",
  title: "På västfronten intet spex",
  year: ~D[2022-05-22],
  or_title: "Test"
})

Haj.Repo.insert!(%Haj.Spex.Group{name: "Bygg"})
Haj.Repo.insert!(%Haj.Spex.Group{name: "Chefsgruppen"})
