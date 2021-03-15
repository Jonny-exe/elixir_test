defmodule ElixirTest.Login do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logins" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 5, max: 15)
  end
end
