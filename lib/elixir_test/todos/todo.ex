defmodule ElixirTest.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :done, :boolean, default: false
    field :title, :string
    field :writer, :string
    field :room, :integer
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :writer, :room, :done, :description])
    |> validate_required([:title, :writer, :room, :done, :description])
    |> validate_length(:title, max: 25, min: 5)
    |> validate_length(:description, max: 200)
  end


  def input_changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
    |> validate_length(:title, max: 25, min: 5)
    |> validate_length(:description, max: 200)
  end
end
