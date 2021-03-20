defmodule ElixirTest.Userrooms.Userroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "userrooms" do
    field :name, :string
    field :roomid, :integer
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :roomid])
    |> validate_required([:name, :roomid])
  end
end
