defmodule Haj.GoogleApiTest do
  use Haj.DataCase

  alias Haj.GoogleApi

  describe "tokens" do
    alias Haj.GoogleApi.Token

    import Haj.GoogleApiFixtures

    @invalid_attrs %{access_token: nil, expire_time: nil, refresh_token: nil}

    test "list_tokens/0 returns all tokens" do
      token = token_fixture()
      assert GoogleApi.list_tokens() == [token]
    end

    test "get_token!/1 returns the token with given id" do
      token = token_fixture()
      assert GoogleApi.get_token!(token.id) == token
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{
        access_token: "some access_token",
        expire_time: ~U[2023-03-04 20:00:00Z],
        refresh_token: "some refresh_token"
      }

      assert {:ok, %Token{} = token} = GoogleApi.create_token(valid_attrs)
      assert token.access_token == "some access_token"
      assert token.expire_time == ~U[2023-03-04 20:00:00Z]
      assert token.refresh_token == "some refresh_token"
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GoogleApi.create_token(@invalid_attrs)
    end

    test "update_token/2 with valid data updates the token" do
      token = token_fixture()

      update_attrs = %{
        access_token: "some updated access_token",
        expire_time: ~U[2023-03-05 20:00:00Z],
        refresh_token: "some updated refresh_token"
      }

      assert {:ok, %Token{} = token} = GoogleApi.update_token(token, update_attrs)
      assert token.access_token == "some updated access_token"
      assert token.expire_time == ~U[2023-03-05 20:00:00Z]
      assert token.refresh_token == "some updated refresh_token"
    end

    test "update_token/2 with invalid data returns error changeset" do
      token = token_fixture()
      assert {:error, %Ecto.Changeset{}} = GoogleApi.update_token(token, @invalid_attrs)
      assert token == GoogleApi.get_token!(token.id)
    end

    test "delete_token/1 deletes the token" do
      token = token_fixture()
      assert {:ok, %Token{}} = GoogleApi.delete_token(token)
      assert_raise Ecto.NoResultsError, fn -> GoogleApi.get_token!(token.id) end
    end

    test "change_token/1 returns a token changeset" do
      token = token_fixture()
      assert %Ecto.Changeset{} = GoogleApi.change_token(token)
    end
  end
end
