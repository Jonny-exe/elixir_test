defmodule ElixirTest.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :name, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:name, :token])
    |> validate_required([:name, :token])
  end
end
