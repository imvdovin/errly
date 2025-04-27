defmodule Errly.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Errly.Spaces.Space

  @type t :: %__MODULE__{}

  # Define supported platforms here or load from config
  @supported_platforms [
    "python.django",
    "python.fastapi",
    "elixir.phoenix"
    # Add more as needed: "javascript.react", "javascript.nodejs", etc.
  ]
  def supported_platforms, do: @supported_platforms

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    # e.g., python.django, elixir.phoenix
    field :platform, :string
    # Redact api_key from logs/inspect
    field :api_key, :string, redact: true

    belongs_to :space, Space

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :platform, :space_id, :api_key])
    # api_key generated separately
    |> validate_required([:name, :platform, :space_id])
    # Ensure api_key is set on insert
    |> validate_required([:api_key], on: :insert)
    |> assoc_constraint(:space)
    |> unique_constraint(:api_key)
    |> validate_length(:name, min: 1)
    |> validate_inclusion(:platform, @supported_platforms, message: "is not a supported platform")
  end
end
