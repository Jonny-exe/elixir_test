defmodule ElixirTest.Repo.Migrations.CreateUserrooms do
  use Ecto.Migration

  def change do
    create table(:userrooms) do
      add :name, :string
      add :roomid, :integer
      add :accepted, :boolean

      timestamps()
    end

  end
end
