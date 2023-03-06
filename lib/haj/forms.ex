defmodule Haj.Forms do
  @moduledoc """
  The Forms context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Forms.Form

  @doc """
  Returns the list of forms.

  ## Examples

      iex> list_forms()
      [%Form{}, ...]

  """
  def list_forms do
    Repo.all(Form)
  end

  @doc """
  Gets a single form.

  Raises `Ecto.NoResultsError` if the Form does not exist.

  ## Examples

      iex> get_form!(123)
      %Form{}

      iex> get_form!(456)
      ** (Ecto.NoResultsError)

  """
  def get_form!(id), do: Repo.get!(Form, id)

  @doc """
  Creates a form.

  ## Examples

      iex> create_form(%{field: value})
      {:ok, %Form{}}

      iex> create_form(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_form(attrs \\ %{}) do
    %Form{}
    |> Form.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a form.

  ## Examples

      iex> update_form(form, %{field: new_value})
      {:ok, %Form{}}

      iex> update_form(form, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_form(%Form{} = form, attrs) do
    form
    |> Form.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a form.

  ## Examples

      iex> delete_form(form)
      {:ok, %Form{}}

      iex> delete_form(form)
      {:error, %Ecto.Changeset{}}

  """
  def delete_form(%Form{} = form) do
    Repo.delete(form)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking form changes.

  ## Examples

      iex> change_form(form)
      %Ecto.Changeset{data: %Form{}}

  """
  def change_form(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end

  alias Haj.Forms.Question

  @doc """
  Returns the list of form_questions.

  ## Examples

      iex> list_form_questions()
      [%Question{}, ...]

  """
  def list_form_questions do
    Repo.all(Question)
  end

  @doc """
  Gets a single form_question.

  Raises `Ecto.NoResultsError` if the Form question does not exist.

  ## Examples

      iex> get_form_question!(123)
      %Question{}

      iex> get_form_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_form_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a form_question.

  ## Examples

      iex> create_form_question(%{field: value})
      {:ok, %Question{}}

      iex> create_form_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_form_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a form_question.

  ## Examples

      iex> update_form_question(form_question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_form_question(form_question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_form_question(%Question{} = form_question, attrs) do
    form_question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a form_question.

  ## Examples

      iex> delete_form_question(form_question)
      {:ok, %Question{}}

      iex> delete_form_question(form_question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_form_question(%Question{} = form_question) do
    Repo.delete(form_question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking form_question changes.

  ## Examples

      iex> change_form_question(form_question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_form_question(%Question{} = form_question, attrs \\ %{}) do
    Question.changeset(form_question, attrs)
  end

  alias Haj.Forms.Response

  @doc """
  Returns the list of form_responses.

  ## Examples

      iex> list_form_responses()
      [%Response{}, ...]

  """
  def list_form_responses do
    Repo.all(Response)
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(123)
      %Response{}

      iex> get_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(id), do: Repo.get!(Response, id)

  @doc """
  Creates a response.

  ## Examples

      iex> create_response(%{field: value})
      {:ok, %Response{}}

      iex> create_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response(attrs \\ %{}) do
    %Response{}
    |> Response.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a response.

  ## Examples

      iex> delete_response(response)
      {:ok, %Response{}}

      iex> delete_response(response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(response)
      %Ecto.Changeset{data: %Response{}}

  """
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end
end
