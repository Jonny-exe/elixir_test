defmodule ElixirTest.Userrooms do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias ElixirTest.Repo

  alias ElixirTest.Userrooms.Userroom
  alias Phoenix.PubSub

  @topic inspect(__MODULE__)

  def subscribe do
    PubSub.subscribe(ElixirTest.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    PubSub.broadcast(ElixirTest.PubSub, @topic, {__MODULE__, event, result})
  end

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_usersroom_by_name(name, accepted) do
    Repo.all(from u in Userroom, where: u.name == ^name and u.accepted == ^accepted)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_userroom_by_name!(name) do
    Repo.get_by!(Userroom, name: name)
  end


  def get_userroom!(id) do
    Repo.get!(Userroom, id)
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_userroom(attrs \\ %{}) do
    %Userroom{}
    |> Userroom.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:userroom, :created])
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_userroom(%Userroom{} = user, attrs) do
    user
    |> Userroom.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:userroom, :updated])
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_userroom(%Userroom{} = userroom) do
    userroom
    |> Repo.delete()
    |> broadcast_change([:userroom, :deleted])

    # post = Repo.get!(Post, 42)
    # case Repo.delete post do
    #   {:ok, struct}        # Deleted with success
    #   {:error, changeset}  # Something went wrong
    # end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_userroom(%Userroom{} = userroom, attrs \\ %{}) do
    Userroom.changeset(userroom, attrs)
  end
end
