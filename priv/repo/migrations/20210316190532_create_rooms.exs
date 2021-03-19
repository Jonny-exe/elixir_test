defmodule ElixirTest.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :creator, :string

      timestamps()
    end

  end
end
