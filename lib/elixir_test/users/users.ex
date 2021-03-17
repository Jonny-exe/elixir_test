defmodule ElixirTest.Users do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias ElixirTest.Repo

  alias ElixirTest.Users.User
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
  def list_users do
    Repo.all(User)
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
  def get_user!(name) do
    Repo.get_by!(User, name: name)
  end


  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:todo, :created])
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:todo, :updated])
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    user
    |> Repo.delete()
    |> broadcast_change([:todo, :deleted])

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
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
