defmodule ElixirTest.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :password, :string
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :password])
    |> validate_required([:name, :password])
    |> unique_constraint(:name, name: :name)
    |> validate_length(:name, min: 5, max: 15)
  end
end
