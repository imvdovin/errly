defmodule Errly.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :platform, :string, null: false
      add :api_key, :string, null: false
      add :space_id, references(:spaces, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:projects, [:space_id])
    create unique_index(:projects, [:api_key], name: :projects_api_key_index)
  end
end
