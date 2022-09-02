defmodule HajWeb.UserView do
  use HajWeb, :view

  def name(user) do
    "#{user.first_name} #{user.last_name}"
  end
end
