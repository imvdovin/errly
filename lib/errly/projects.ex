defmodule Errly.Projects do
  @moduledoc """
  The Projects context.
  Manages projects within spaces, including API keys for SDKs.
  """

  import Ecto.Query, warn: false
  alias Errly.Repo

  alias Errly.Projects.Project
  alias Errly.Spaces.Space
  alias Errly.Accounts.Scope
  alias Errly.Accounts.User
  alias Errly.Spaces

  @api_key_bytes 64

  # === Public API ===

  @doc """
  Returns the list of projects for a given space.

  Requires the user to be a participant of the space.
  """
  def list_projects(%Scope{} = scope, %Space{id: space_id}) do
    # Verify participation by fetching the space
    Spaces.get_space!(scope, space_id)
    projects = Repo.all(from p in Project, where: p.space_id == ^space_id)
    # Hide api_key before returning
    Enum.map(projects, &Map.delete(&1, :api_key))
  end

  @doc """
  Gets a single project by ID, ensuring the user is a participant of the space.
  Does NOT include the api_key in the returned struct.

  Raises `Ecto.NoResultsError` if not found or user is not a participant.
  """
  def get_project!(%Scope{} = scope, id) do
    project = Repo.get!(Project, id)
    # Verify participation in the project's space
    Spaces.get_space!(scope, project.space_id)
    # Hide api_key before returning
    Map.delete(project, :api_key)
  end

  @doc """
  Creates a project within a specific space.

  Generates a unique API key automatically.
  Requires the user to be an owner or admin of the space.
  Returns {:ok, project_with_key} on success, where project_with_key includes the generated api_key.
  """
  def create_project(%Scope{user: user} = scope, %Space{} = space, attrs) do
    with :ok <- check_role(user, space, [:owner, :admin]),
         api_key <- generate_unique_api_key(),
         attrs_with_key = Map.put(attrs, "api_key", api_key) |> Map.put("space_id", space.id) do
      %Project{}
      |> Project.changeset(attrs_with_key)
      |> Repo.insert()

      # Note: Repo.insert() returns {:ok, project}, which will include the api_key here.
      # No need to explicitly add it back.
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a project's editable attributes (e.g., name, platform).

  Requires the user to be an owner or admin of the space.
  """
  def update_project(%Scope{user: user} = scope, %Project{} = project, attrs) do
    # Verify participation and get the space
    space = Spaces.get_space!(scope, project.space_id)

    with :ok <- check_role(user, space, [:owner, :admin]) do
      project
      |> Project.changeset(attrs)
      |> Repo.update()
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes a project.

  Requires the user to be the owner of the space.
  """
  def delete_project(%Scope{user: user} = scope, %Project{} = project) do
    # Verify participation and get the space
    space = Spaces.get_space!(scope, project.space_id)

    with :ok <- check_role(user, space, [:owner]) do
      Repo.delete(project)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates and assigns a new API key to the project.

  Requires the user to be the owner of the space.
  Returns `{:ok, project_with_new_key}` with the new key or `{:error, reason}`.
  """
  def regenerate_api_key(%Scope{user: user} = scope, %Project{} = project) do
    # Verify participation and get the space
    space = Spaces.get_space!(scope, project.space_id)

    with :ok <- check_role(user, space, [:owner]),
         new_key <- generate_unique_api_key() do
      project
      |> Project.changeset(%{api_key: new_key})
      |> Repo.update()

      # Note: Repo.update() returns {:ok, project}, which will include the new api_key here.
      # No need to explicitly add it back.
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  Requires the user to be an owner or admin of the space.
  """
  def change_project(%Scope{user: user} = scope, %Project{} = project, attrs \\ %{}) do
    # Verify participation and get the space
    space = Spaces.get_space!(scope, project.space_id)

    case check_role(user, space, [:owner, :admin]) do
      :ok -> Project.changeset(project, attrs)
      {:error, reason} -> {:error, reason}
    end
  end

  # === Private Helpers ===

  @doc false
  def generate_api_key() do
    :crypto.strong_rand_bytes(@api_key_bytes)
    |> Base.url_encode64(padding: false)
  end

  # Generates API keys until a unique one is found.
  # In practice, collisions are extremely unlikely with 64 random bytes.
  defp generate_unique_api_key() do
    api_key = generate_api_key()

    if Repo.get_by(Project, api_key: api_key) do
      # Retry if collision (highly improbable)
      generate_unique_api_key()
    else
      api_key
    end
  end

  # Checks if the user has one of the required roles in the space.
  # Returns :ok or {:error, :unauthorized}.
  defp check_role(%User{} = user, %Space{} = space, required_roles)
       when is_list(required_roles) do
    case Spaces.get_participant_role(user, space) do
      nil ->
        # User is not a participant
        {:error, :unauthorized}

      role ->
        if role in required_roles do
          # User has one of the required roles
          :ok
        else
          # User role is not sufficient
          {:error, :unauthorized}
        end
    end
  end
end
