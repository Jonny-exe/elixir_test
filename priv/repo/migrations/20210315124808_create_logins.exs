defmodule ElixirTest.Repo.Migrations.CreateLogins do
  use Ecto.Migration

  def change do
    create table(:logins) do
      add :name, :string

      timestamps()
    end

  end
end
