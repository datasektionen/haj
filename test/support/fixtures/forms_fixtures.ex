defmodule Haj.FormsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Forms` context.
  """

  @doc """
  Generate a form.
  """
  def form_fixture(attrs \\ %{}) do
    {:ok, form} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Haj.Forms.create_form()

    form
  end

  @doc """
  Generate a form_question.
  """
  def form_question_fixture(attrs \\ %{}) do
    {:ok, form_question} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        required: true,
        type: :text
      })
      |> Haj.Forms.create_form_question()

    form_question
  end

  @doc """
  Generate a response.
  """
  def response_fixture(attrs \\ %{}) do
    {:ok, response} =
      attrs
      |> Enum.into(%{
        value: "some value"
      })
      |> Haj.Forms.create_response()

    response
  end

  @doc """
  Generate a question_response.
  """
  def question_response_fixture(attrs \\ %{}) do
    {:ok, question_response} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        multi_answer: ["option1", "option2"]
      })
      |> Haj.Forms.create_question_response()

    question_response
  end
end
