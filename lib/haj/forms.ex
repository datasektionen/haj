defmodule Haj.Forms do
  @moduledoc """
  The Forms context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo
  alias Ecto.Multi

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

  def search_forms(search_phrase) do
    query =
      from f in Form,
        where: fragment("? %> ?", f.name, ^search_phrase),
        order_by: {:desc, fragment("word_similarity(?, ?)", f.name, ^search_phrase)}

    Repo.all(query)
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
  def get_form!(id) do
    Repo.one!(
      from f in Form,
        where: f.id == ^id,
        left_join: q in assoc(f, :questions),
        preload: [questions: q]
    )
  end

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

  @doc """
  Retruns a changeset for a form submission
  """
  def get_form_changeset!(form_id, %Response{} = response) do
    attrs =
      response.question_responses
      |> Enum.reduce(%{}, fn qr, acc ->
        Map.put(acc, String.to_atom("#{qr.question_id}"), qr.answer || qr.multi_answer)
      end)

    get_form_changeset!(form_id, attrs)
  end

  def get_form_changeset!(form_id, attrs) do
    query =
      from f in Form,
        where: f.id == ^form_id,
        left_join: q in assoc(f, :questions),
        preload: [questions: q]

    form = Repo.one!(query)

    data = %{}

    types =
      Enum.reduce(form.questions, %{}, fn q, acc ->
        case q.type do
          :multi_select ->
            Map.put(acc, String.to_atom("#{q.id}"), {:array, :string})

          _ ->
            Map.put(acc, String.to_atom("#{q.id}"), :string)
        end
      end)

    {data, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> validate_required(form.questions)
    |> validate_options(form.questions)
  end

  defp validate_required(changeset, questions) do
    required =
      Enum.filter(questions, fn %{required: req} -> req end)
      |> Enum.map(fn %{id: id} -> String.to_atom("#{id}") end)

    Ecto.Changeset.validate_required(changeset, required)
  end

  defp validate_options(changeset, questions) do
    Enum.reduce(questions, changeset, fn q, acc ->
      field = String.to_atom("#{q.id}")

      case q.type do
        :select ->
          acc
          |> Ecto.Changeset.validate_change(field, fn field, value ->
            case value in q.options do
              true -> []
              false -> [{field, "Value must be an availible option"}]
            end
          end)

        :multi_select ->
          acc
          |> Ecto.Changeset.validate_change(field, fn field, values ->
            case Enum.all?(values, &Enum.member?(q.options, &1)) do
              true -> []
              false -> [{field, "All values must be availible options"}]
            end
          end)

        _ ->
          acc
      end
    end)
  end

  alias Haj.Forms.QuestionResponse

  @doc """
  Returns the list of form_question_responses.

  ## Examples

      iex> list_form_question_responses()
      [%QuestionResponse{}, ...]

  """
  def list_form_question_responses do
    Repo.all(QuestionResponse)
  end

  @doc """
  Gets a single question_response.

  Raises `Ecto.NoResultsError` if the Question response does not exist.

  ## Examples

      iex> get_question_response!(123)
      %QuestionResponse{}

      iex> get_question_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question_response!(id), do: Repo.get!(QuestionResponse, id)

  @doc """
  Creates a question_response.

  ## Examples

      iex> create_question_response(%{field: value})
      {:ok, %QuestionResponse{}}

      iex> create_question_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question_response(attrs \\ %{}) do
    %QuestionResponse{}
    |> QuestionResponse.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question_response.

  ## Examples

      iex> update_question_response(question_response, %{field: new_value})
      {:ok, %QuestionResponse{}}

      iex> update_question_response(question_response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question_response(%QuestionResponse{} = question_response, attrs) do
    question_response
    |> QuestionResponse.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question_response.

  ## Examples

      iex> delete_question_response(question_response)
      {:ok, %QuestionResponse{}}

      iex> delete_question_response(question_response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question_response(%QuestionResponse{} = question_response) do
    Repo.delete(question_response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question_response changes.

  ## Examples

      iex> change_question_response(question_response)
      %Ecto.Changeset{data: %QuestionResponse{}}

  """
  def change_question_response(%QuestionResponse{} = question_response, attrs \\ %{}) do
    QuestionResponse.changeset(question_response, attrs)
  end

  @doc """
  Submits a form response for a user and form. Creates a response, as well as
  all the question responses for the form.
  """
  def submit_form(form_id, user_id, attrs) do
    changeset = get_form_changeset!(form_id, attrs)

    case changeset |> Ecto.Changeset.apply_action(:create) do
      {:ok, data} ->
        question_responses =
          Enum.map(data, fn {key, val} ->
            id = Atom.to_string(key) |> String.to_integer()

            case val do
              ans when is_list(ans) -> %QuestionResponse{question_id: id, multi_answer: ans}
              ans -> %QuestionResponse{question_id: id, answer: ans}
            end
          end)

        multi =
          Multi.new()
          |> Multi.insert(:response, %Response{
            user_id: user_id,
            form_id: form_id
          })

        {_n, multi} =
          Enum.reduce(question_responses, {0, multi}, fn qr, {n, m} ->
            {n + 1,
             Multi.insert(m, n, fn %{response: %{id: id}} ->
               %QuestionResponse{qr | response_id: id}
             end)}
          end)

        Repo.transaction(multi)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a form response for a form. Modifies the response, as well as
  replaces all the question responses with new answers.
  """
  def update_form_response(form_id, form_response, attrs) do
    changeset = get_form_changeset!(form_id, attrs)

    case changeset |> Ecto.Changeset.apply_action(:create) do
      {:ok, data} ->
        question_responses =
          Enum.map(data, fn {key, val} ->
            id = Atom.to_string(key) |> String.to_integer()

            case val do
              ans when is_list(ans) -> %QuestionResponse{question_id: id, multi_answer: ans}
              ans -> %QuestionResponse{question_id: id, answer: ans}
            end
          end)

        multi =
          Multi.new()
          |> Multi.delete_all(
            :question_responses,
            from(qr in QuestionResponse, where: qr.response_id == ^form_response.id)
          )

        {_n, multi} =
          Enum.reduce(question_responses, {0, multi}, fn qr, {n, m} ->
            {n + 1,
             Multi.insert(m, n, fn _ ->
               %QuestionResponse{qr | response_id: form_response.id}
             end)}
          end)

        Repo.transaction(multi)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns a form response for a user and form, if one exists.
  """
  def get_event_response_for_user(event_id, user_id) do
    query =
      from r in Response,
        join: er in assoc(r, :event_registration),
        join: e in assoc(er, :event),
        where: r.user_id == ^user_id and e.id == ^event_id,
        preload: [question_responses: []]

    Repo.one(query)
  end
end
