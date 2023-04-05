defmodule Haj.Policy.Checks do
  alias Haj.Responsibilities.Comment
  alias Haj.Responsibilities
  alias Haj.Responsibilities.Responsibility
  alias Haj.Accounts.User
  alias Haj.Spex

  def self(%User{id: id}, %User{id: id}, _) when is_binary(id), do: true

  def role(%User{role: role}, _object, role), do: true
  def role(_, _, _), do: false

  def spex_member(%User{} = user, _), do: Spex.member_of_any_spex?(user)

  def current_spex_member(%User{} = user, _), do: Spex.member_of_spex?(Spex.current_spex(), user)

  def current_group_member(%User{id: user_id}, _, group_permission) do
    Spex.curent_member_of_group_with_permission?(user_id, group_permission)
  end

  def group_member(%User{id: user_id}, _, group_permission) do
    Spex.member_of_group_with_permission?(user_id, group_permission)
  end

  def has_responsibility(%User{} = user, %Responsibility{} = responsibility) do
    Responsibilities.has_had_responsibility?(responsibility, user)
  end

  def own_comment(%User{} = user, %Comment{} = comment), do: comment.user_id == user.id
end
