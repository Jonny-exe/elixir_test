defmodule ElixirTest.Tokens do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias ElixirTest.Repo

  alias ElixirTest.Tokens.Token

  def get_token!(name) do
    query =
      from user in "tokens",
        where: user.name == ^name,
        select: user.token

    Repo.all(query)
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token(%Token{} = token) do
    token
    |> Repo.delete()

    # post = Repo.get!(Post, 42)
    # case Repo.delete post do
    #   {:ok, struct}        # Deleted with success
    #   {:error, changeset}  # Something went wrong
    # end
  end
end
