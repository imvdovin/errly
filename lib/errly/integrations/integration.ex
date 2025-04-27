defmodule Errly.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Spaces.Space

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "integrations" do
    field :name, :string
    # e.g., "slack", "github", "webhook"
    field :type, :string
    field :settings, :map, default: %{}
    field :enabled, :boolean, default: true

    belongs_to :space, Space

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:name, :type, :settings, :enabled, :space_id])
    |> validate_required([:name, :type, :space_id])
    |> assoc_constraint(:space)

    # Add potential unique constraints here, e.g.,
    # |> unique_constraint(:name, name: :integrations_space_id_name_index, message: "already exists in this space")
    # |> unique_constraint([:space_id, :type], name: :integrations_space_id_type_index, message: "of this type already exists in this space")
  end
end
