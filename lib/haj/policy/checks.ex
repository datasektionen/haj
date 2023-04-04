defmodule Haj.Policy.Checks do
  alias Haj.Accounts.User

  def self(%User{id: id}, %User{id: id}, _) when is_binary(id), do: true

  def role(%User{role: role}, _object, role), do: true
  def role(_, _, _), do: false
end
