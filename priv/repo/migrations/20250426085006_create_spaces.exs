defmodule Errly.Repo.Migrations.CreateSpaces do
  use Ecto.Migration

  def change do
    create table(:spaces, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:spaces, [:slug])

    create table(:participants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false
      add :space_id, references(:spaces, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:participants, [:user_id, :space_id])
  end
end
