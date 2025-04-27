defmodule Errly.Integrations do
  @moduledoc """
  The Integrations context.
  """

  import Ecto.Query, warn: false
  alias Errly.Repo

  alias Errly.Integrations.Integration
  alias Errly.Spaces.Space
  alias Errly.Accounts.Scope
  alias Errly.Accounts.User
  alias Errly.Spaces

  @doc """
  Returns the list of integrations for a given space.

  Requires the user to be a participant of the space.

  ## Examples

      iex> list_integrations(scope, space)
      [%Integration{}, ...]

      iex> list_integrations(scope, non_member_space)
      ** (Ecto.NoResultsError) # Or returns empty list depending on desired behavior

  """
  def list_integrations(%Scope{} = scope, %Space{id: space_id}) do
    # First, verify the user is a participant of the space by fetching it
    # This will raise Ecto.NoResultsError if not a participant
    Spaces.get_space!(scope, space_id)

    # If successful, list integrations for that space
    Repo.all(from i in Integration, where: i.space_id == ^space_id)
  end

  @doc """
  Gets a single integration by ID, ensuring the user is a participant of the space.

  Raises `Ecto.NoResultsError` if the Integration/Space does not exist or the user is not a participant.

  ## Examples

      iex> get_integration!(scope, 123)
      %Integration{}

      iex> get_integration!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_integration!(%Scope{} = scope, id) do
    integration =
      Repo.get!(Integration, id)
      |> Repo.preload(:space)

    # Verify the user is a participant of the integration's space
    # This will raise if space is nil or user is not a participant
    Spaces.get_space!(scope, integration.space_id)

    integration
  end

  @doc """
  Creates an integration for a specific space.

  Requires the user to be the owner of the space.

  ## Examples

      iex> create_integration(scope, owner_space, %{field: value})
      {:ok, %Integration{}}

      iex> create_integration(scope, non_owner_space, %{field: value})
      {:error, :unauthorized}

      iex> create_integration(scope, space, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_integration(%Scope{user: user} = scope, %Space{} = space, attrs) do
    # Verify the user is the owner of the space
    case Spaces.get_participant_role(user, space) do
      :owner ->
        %Integration{}
        |> Integration.changeset(Map.put(attrs, "space_id", space.id))
        |> Repo.insert()

      # Add broadcasting if needed
      _ ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Updates an integration.

  Requires the user to be the owner of the space the integration belongs to.

  ## Examples

      iex> update_integration(scope, integration, %{field: new_value})
      {:ok, %Integration{}}

      iex> update_integration(non_owner_scope, integration, %{field: new_value})
      {:error, :unauthorized}

      iex> update_integration(scope, integration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_integration(%Scope{user: user} = scope, %Integration{} = integration, attrs) do
    # Preload space for role check & ensure user participation via get_integration!
    integration_with_space = get_integration!(scope, integration.id)

    # Check if the user is the owner
    case Spaces.get_participant_role(user, integration_with_space.space) do
      :owner ->
        integration
        |> Integration.changeset(attrs)
        |> Repo.update()

      # Add broadcasting if needed
      _ ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Deletes an integration.

  Requires the user to be the owner of the space the integration belongs to.

  ## Examples

      iex> delete_integration(scope, integration)
      {:ok, %Integration{}}

      iex> delete_integration(non_owner_scope, integration)
      {:error, :unauthorized}

  """
  def delete_integration(%Scope{user: user} = scope, %Integration{} = integration) do
    # Preload space for role check & ensure user participation via get_integration!
    integration_with_space = get_integration!(scope, integration.id)

    # Check if the user is the owner
    case Spaces.get_participant_role(user, integration_with_space.space) do
      :owner ->
        Repo.delete(integration)

      # Add broadcasting if needed
      _ ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking integration changes.

  Requires the user to be the owner of the space the integration belongs to.

  ## Examples

      iex> change_integration(scope, integration)
      %Ecto.Changeset{data: %Integration{}}

      iex> change_integration(non_owner_scope, integration)
      {:error, :unauthorized}

  """
  def change_integration(%Scope{user: user} = scope, %Integration{} = integration, attrs \\ %{}) do
    # Preload space for role check & ensure user participation via get_integration!
    integration_with_space = get_integration!(scope, integration.id)

    # Check if the user is the owner
    case Spaces.get_participant_role(user, integration_with_space.space) do
      :owner ->
        Integration.changeset(integration, attrs)

      _ ->
        # Returning {:error, :unauthorized} might be confusing here,
        # as the function usually returns a changeset.
        # Maybe return an invalid changeset instead?
        # For now, stick to :unauthorized for consistency.
        {:error, :unauthorized}
    end
  end

  # Optional: Add broadcasting functions if needed
  # defp broadcast_change({:ok, integration}), do: # ... broadcast logic ...
  # defp broadcast_change({:error, _} = error), do: error # Passthrough errors
end
