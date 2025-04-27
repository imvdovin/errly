defmodule Errly.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :settings, :map, default: fragment("'{}'::jsonb"), null: false
      add :enabled, :boolean, default: true, null: false
      add :space_id, references(:spaces, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:integrations, [:space_id])
    # Optional: Add unique index for name per space
    # create unique_index(:integrations, [:space_id, :name], name: :integrations_space_id_name_index)
    # Optional: Add unique index for type per space
    # create unique_index(:integrations, [:space_id, :type], name: :integrations_space_id_type_index)
  end
end
