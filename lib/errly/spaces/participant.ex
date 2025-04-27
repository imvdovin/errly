defmodule Errly.Spaces.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Accounts.User
  alias Errly.Spaces.Space

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participants" do
    field :role, Ecto.Enum, values: [:owner, :admin, :member], default: :member

    belongs_to :user, User
    belongs_to :space, Space

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role, :user_id, :space_id])
    |> validate_required([:user_id, :space_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:space_id)
    |> unique_constraint([:user_id, :space_id], name: :participants_user_id_space_id_index)
  end
end
