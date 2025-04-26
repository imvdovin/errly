defmodule Errly.Spaces.Space do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Spaces.Participant

  schema "spaces" do
    field :name, :string
    field :slug, :string
    has_many :participants, Participant

    timestamps(type: :utc_datetime)
  end

  def changeset(space, attrs) do
    space
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
