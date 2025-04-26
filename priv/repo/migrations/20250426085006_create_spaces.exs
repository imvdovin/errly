defmodule Errly.Repo.Migrations.CreateSpaces do
  use Ecto.Migration

  def change do
    create table(:spaces) do
      add :name, :string
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create table(:participants) do
      add :role, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)
      add :space_id, references(:spaces, type: :id, on_delete: :delete_all)
    end
  end
end
