defmodule ElixirTest.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :name, :string
      add :token, :string

      timestamps()
    end

  end
end
