defmodule ElixirTest.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias ElixirTest.Repo

  alias ElixirTest.Rooms.Room
  alias Phoenix.PubSub

  @topic inspect(__MODULE__)

  def subscribe do
    PubSub.subscribe(ElixirTest.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    PubSub.broadcast(ElixirTest.PubSub, @topic, {__MODULE__, event, result})
  end

  @doc """
  Returns the list of rooms.

  ## Examples
i
      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_room!(123)
      %Todo{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Todo{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:room, :created])
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_room(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_room(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = todo, attrs) do
    todo
    |> Room.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:room, :updated])
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_room(todo)
      {:ok, %Todo{}}

      iex> delete_room(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = todo) do
    todo
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

      iex> change_room(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end
