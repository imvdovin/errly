defmodule Errly.Spaces.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Accounts.User
  alias Errly.Spaces.Space

  schema "participants" do
    field :role, Ecto.Enum, values: [:admin, :member]

    belongs_to :user, User
    belongs_to :space, Space

    timestamps(type: :utc_datetime)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role, :user_id, :space_id])
    |> validate_required([:role, :user_id, :space_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:space_id)
  end
end
