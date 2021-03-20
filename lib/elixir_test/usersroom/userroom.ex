defmodule ElixirTest.Userrooms.Userroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "userrooms" do
    field :name, :string
    field :roomid, :integer
    field :accepted, :boolean
    timestamps()
  end

  @doc false
  def changeset(userroom, attrs) do
    userroom
    |> cast(attrs, [:name, :roomid, :accepted])
    |> validate_required([:name, :roomid, :accepted])
  end
end
