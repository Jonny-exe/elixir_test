defmodule ElixirTest.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :done, :boolean, default: false, null: false
      add :writer, :string
      add :room, :integer

      timestamps()
    end
  end
end
