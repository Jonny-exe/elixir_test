defmodule ElixirTest.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :done, :boolean, default: false
    field :title, :string
    field :writer, :string
    field :room, :integer

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :writer, :room, :done])
    |> validate_required([:title, :writer, :room, :done])
  end
end
