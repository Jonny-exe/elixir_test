defmodule ElixirTest.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :creator, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :creator])
    |> validate_required([:name, :creator])
    |> validate_length(:name, max: 20, min: 5)
  end

  def input_changeset(room, attrs) do # The same but without creator
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 20, min: 5)
  end
end
