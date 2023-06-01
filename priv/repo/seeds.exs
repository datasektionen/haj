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
alias Haj.Repo
alias Haj.Accounts.User
import Ecto.Query

show =
  Repo.insert!(%Haj.Spex.Show{
    description: "Coolt spex",
    title: "På västfronten intet spex",
    year: ~D[2022-05-23],
    or_title: "Test"
  })

# Users

user_data =
  [
    %User{first_name: "Adrian", last_name: "Salamon", username: "asalamon", role: :admin},
    %User{first_name: "Hampus", last_name: "Hallkvist", username: "hallkvi", role: :admin},
    %User{first_name: "Isak", last_name: "Lefevre", username: "lefevre", role: :admin},
    %User{first_name: "Martin", last_name: "Ryberg Laude", username: "mrl", role: :admin}
  ]
  |> Enum.map(fn user ->
    %User{user | email: "#{user.username}@kth.se"}
  end)

users =
  Enum.map(user_data, fn user ->
    case Repo.one(from u in User, where: u.username == ^user.username) do
      nil -> Repo.insert!(user)
      u -> u
    end
  end)

# Groups

groups = ~w"Webb Chefsgruppen Bygg Lallarna"

show_groups =
  Enum.map(groups, fn name ->
    group = Repo.insert!(%Haj.Spex.Group{name: name})

    show_group =
      Ecto.build_assoc(group, :show_groups, %{show: show})
      |> Repo.insert!()

    shuffled = Enum.shuffle(users)

    Ecto.build_assoc(show_group, :group_memberships, %{
      show: show,
      user: Enum.at(shuffled, 1),
      role: :chef
    })
    |> Repo.insert!()

    Ecto.build_assoc(show_group, :group_memberships, %{
      show: show,
      user: Enum.at(shuffled, 2),
      role: :gruppis
    })
    |> Repo.insert!()

    Ecto.build_assoc(show_group, :group_memberships, %{
      show: show,
      user: Enum.at(shuffled, 3),
      role: :gruppis
    })
    |> Repo.insert!()

    show_group
  end)

# Foods

foods = ~w"Laktos Vegan Gluten"

Enum.each(foods, fn food ->
  food = Repo.insert!(%Haj.Foods.Food{name: food})

  Enum.random(users)
  |> Repo.preload(:foods)
  |> Haj.Accounts.User.changeset()
  |> Ecto.Changeset.put_assoc(:foods, [food])
  |> Haj.Repo.update!()
end)

# Applications

app_user_data =
  [
    %User{first_name: "Spex", last_name: "Spexsson", username: "spexsson", role: :none},
    %User{first_name: "Spexare", last_name: "Maximus", username: "maxspex", role: :none},
    %User{first_name: "Sältränare", last_name: "Klimt", username: "sältränare", role: :none}
  ]
  |> Enum.map(fn user ->
    %User{user | email: "#{user.username}@kth.se"}
  end)

applicants =
  Enum.map(app_user_data, fn user ->
    case Repo.one(from u in User, where: u.username == ^user.username) do
      nil -> Repo.insert!(user)
      u -> u
    end
  end)

Enum.each(applicants, fn user ->
  Repo.transaction(fn ->
    previous =
      Repo.one(
        from a in Haj.Applications.Application,
          where: a.show_id == ^show.id and a.user_id == ^user.id
      )

    if previous != nil do
      Repo.delete!(previous)
    end

    application = Repo.insert!(%Haj.Applications.Application{user: user, show: show})

    application_groups = show_groups |> Enum.shuffle() |> Enum.take(2)

    Enum.each(application_groups, fn group ->
      Repo.insert!(%Haj.Applications.ApplicationShowGroup{
        application: application,
        show_group: group
      })
    end)
  end)
end)
