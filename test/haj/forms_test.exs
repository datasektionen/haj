defmodule Haj.FormsTest do
  use Haj.DataCase

  alias Haj.Forms

  describe "forms" do
    alias Haj.Forms.Form

    import Haj.FormsFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_forms/0 returns all forms" do
      form = form_fixture()
      assert Forms.list_forms() == [form]
    end

    test "get_form!/1 returns the form with given id" do
      form = form_fixture()
      assert Forms.get_form!(form.id) == form
    end

    test "create_form/1 with valid data creates a form" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Form{} = form} = Forms.create_form(valid_attrs)
      assert form.description == "some description"
      assert form.name == "some name"
    end

    test "create_form/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forms.create_form(@invalid_attrs)
    end

    test "update_form/2 with valid data updates the form" do
      form = form_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Form{} = form} = Forms.update_form(form, update_attrs)
      assert form.description == "some updated description"
      assert form.name == "some updated name"
    end

    test "update_form/2 with invalid data returns error changeset" do
      form = form_fixture()
      assert {:error, %Ecto.Changeset{}} = Forms.update_form(form, @invalid_attrs)
      assert form == Forms.get_form!(form.id)
    end

    test "delete_form/1 deletes the form" do
      form = form_fixture()
      assert {:ok, %Form{}} = Forms.delete_form(form)
      assert_raise Ecto.NoResultsError, fn -> Forms.get_form!(form.id) end
    end

    test "change_form/1 returns a form changeset" do
      form = form_fixture()
      assert %Ecto.Changeset{} = Forms.change_form(form)
    end
  end

  describe "form_questions" do
    alias Haj.Forms.Question

    import Haj.FormsFixtures

    @invalid_attrs %{description: nil, name: nil, required: nil, type: nil}

    test "list_form_questions/0 returns all form_questions" do
      form_question = form_question_fixture()
      assert Forms.list_form_questions() == [form_question]
    end

    test "get_form_question!/1 returns the form_question with given id" do
      form_question = form_question_fixture()
      assert Forms.get_form_question!(form_question.id) == form_question
    end

    test "create_form_question/1 with valid data creates a form_question" do
      valid_attrs = %{
        description: "some description",
        name: "some name",
        required: true,
        type: :text
      }

      assert {:ok, %Question{} = form_question} = Forms.create_form_question(valid_attrs)
      assert form_question.description == "some description"
      assert form_question.name == "some name"
      assert form_question.required == true
      assert form_question.type == :text
    end

    test "create_form_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forms.create_form_question(@invalid_attrs)
    end

    test "update_form_question/2 with valid data updates the form_question" do
      form_question = form_question_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        required: false,
        type: :select
      }

      assert {:ok, %Question{} = form_question} =
               Forms.update_form_question(form_question, update_attrs)

      assert form_question.description == "some updated description"
      assert form_question.name == "some updated name"
      assert form_question.required == false
      assert form_question.type == :select
    end

    test "update_form_question/2 with invalid data returns error changeset" do
      form_question = form_question_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Forms.update_form_question(form_question, @invalid_attrs)

      assert form_question == Forms.get_form_question!(form_question.id)
    end

    test "delete_form_question/1 deletes the form_question" do
      form_question = form_question_fixture()
      assert {:ok, %Question{}} = Forms.delete_form_question(form_question)
      assert_raise Ecto.NoResultsError, fn -> Forms.get_form_question!(form_question.id) end
    end

    test "change_form_question/1 returns a form_question changeset" do
      form_question = form_question_fixture()
      assert %Ecto.Changeset{} = Forms.change_form_question(form_question)
    end
  end

  describe "form_responses" do
    alias Haj.Forms.Response

    import Haj.FormsFixtures

    @invalid_attrs %{value: nil}

    test "list_form_responses/0 returns all form_responses" do
      response = response_fixture()
      assert Forms.list_form_responses() == [response]
    end

    test "get_response!/1 returns the response with given id" do
      response = response_fixture()
      assert Forms.get_response!(response.id) == response
    end

    test "create_response/1 with valid data creates a response" do
      valid_attrs = %{value: "some value"}

      assert {:ok, %Response{} = response} = Forms.create_response(valid_attrs)
      assert response.value == "some value"
    end

    test "create_response/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forms.create_response(@invalid_attrs)
    end

    test "update_response/2 with valid data updates the response" do
      response = response_fixture()
      update_attrs = %{value: "some updated value"}

      assert {:ok, %Response{} = response} = Forms.update_response(response, update_attrs)
      assert response.value == "some updated value"
    end

    test "update_response/2 with invalid data returns error changeset" do
      response = response_fixture()
      assert {:error, %Ecto.Changeset{}} = Forms.update_response(response, @invalid_attrs)
      assert response == Forms.get_response!(response.id)
    end

    test "delete_response/1 deletes the response" do
      response = response_fixture()
      assert {:ok, %Response{}} = Forms.delete_response(response)
      assert_raise Ecto.NoResultsError, fn -> Forms.get_response!(response.id) end
    end

    test "change_response/1 returns a response changeset" do
      response = response_fixture()
      assert %Ecto.Changeset{} = Forms.change_response(response)
    end
  end
end
