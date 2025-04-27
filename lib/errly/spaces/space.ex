defmodule Errly.Spaces.Space do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Spaces.Participant
  alias Errly.Integrations.Integration
  alias Errly.Projects.Project
  alias Errly.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "spaces" do
    field :name, :string
    field :slug, :string

    belongs_to :user, User
    has_many :participants, Participant
    has_many :integrations, Integration
    has_many :projects, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(space, attrs) do
    space
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
