defmodule Errly.Spaces do
  @moduledoc """
  The Spaces context.
  """

  import Ecto.Query, warn: false
  alias Errly.Repo

  alias Errly.Spaces.Space
  alias Errly.Accounts.Scope
  alias Errly.Spaces.Participant
  alias Errly.Accounts.User

  @doc """
  Subscribes to scoped notifications about any space changes.

  The broadcasted messages match the pattern:

    * {:created, %Space{}}
    * {:updated, %Space{}}
    * {:deleted, %Space{}}

  """
  def subscribe_spaces(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Errly.PubSub, "user:#{key}:spaces")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Errly.PubSub, "user:#{key}:spaces", message)
  end

  @doc """
  Returns the list of spaces the user is a participant of.

  ## Examples

      iex> list_spaces(scope)
      [%Space{}, ...]

  """
  def list_spaces(%Scope{user: user}) do
    query =
      from s in Space,
        join: p in assoc(s, :participants),
        where: p.user_id == ^user.id,
        select: s

    Repo.all(query)
  end

  @doc """
  Gets a single space, ensuring the user is a participant.

  Raises `Ecto.NoResultsError` if the Space does not exist or the user is not a participant.

  ## Examples

      iex> get_space!(scope, 123)
      %Space{}

      iex> get_space!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_space!(%Scope{user: user}, id) do
    query =
      from s in Space,
        join: p in assoc(s, :participants),
        where: s.id == ^id and p.user_id == ^user.id,
        select: s,
        limit: 1

    Repo.one!(query)
  end

  @doc """
  Creates a space and makes the creator the owner.

  Runs within a transaction.

  ## Examples

      iex> create_space(scope, %{field: value})
      {:ok, %Space{}}

      iex> create_space(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_space(%Scope{user: user} = scope, attrs) do
    Repo.transaction(fn ->
      with {:ok, space} <-
             %Space{}
             |> Space.changeset(attrs)
             |> Repo.insert(),
           # Make the creator the owner
           {:ok, _participant} <-
             %Participant{}
             |> Participant.changeset(%{
               user_id: user.id,
               space_id: space.id,
               # Explicitly set owner role
               role: :owner
             })
             |> Repo.insert() do
        # Consider broadcasting after transaction potentially?
        # broadcast(scope, {:created, space})
        {:ok, space}
      else
        {:error, changeset} -> Repo.rollback(changeset)
        error -> Repo.rollback(error)
      end
    end)
    |> case do
      {:ok, {:ok, space}} ->
        # Broadcast outside the transaction on final success
        broadcast(scope, {:created, space})
        {:ok, space}

      # Rolled back inner error
      {:ok, {:error, reason}} ->
        {:error, reason}

      # Transaction failed
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a space. Requires admin or owner role.

  ## Examples

      iex> update_space(scope, space, %{field: new_value})
      {:ok, %Space{}}

      iex> update_space(scope, space, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_space(%Scope{user: user} = scope, %Space{} = space, attrs) do
    # Check if user is an admin or owner participant first
    case get_participant_role(user, space) do
      :owner -> do_update_space(scope, space, attrs)
      :admin -> do_update_space(scope, space, attrs)
      _ -> {:error, :unauthorized}
    end
  end

  defp do_update_space(scope, space, attrs) do
    with {:ok, space = %Space{}} <-
           space
           |> Space.changeset(attrs)
           |> Repo.update() do
      broadcast(scope, {:updated, space})
      {:ok, space}
    end
  end

  @doc """
  Deletes a space. Requires owner role.

  ## Examples

      iex> delete_space(scope, space)
      {:ok, %Space{}}

      iex> delete_space(scope, space)
      {:error, :unauthorized}

  """
  def delete_space(%Scope{user: user} = scope, %Space{} = space) do
    # Check if user is the owner participant first
    case get_participant_role(user, space) do
      :owner ->
        with {:ok, space = %Space{}} <-
               Repo.delete(space) do
          broadcast(scope, {:deleted, space})
          {:ok, space}
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking space changes. Requires admin or owner role.

  ## Examples

      iex> change_space(scope, space)
      %Ecto.Changeset{data: %Space{}}

  """
  def change_space(%Scope{user: user} = _scope, %Space{} = space, attrs \\ %{}) do
    # Check if user is an admin or owner participant first
    case get_participant_role(user, space) do
      :owner -> Space.changeset(space, attrs)
      :admin -> Space.changeset(space, attrs)
      # Or maybe just return an invalid changeset?
      _ -> {:error, :unauthorized}
    end
  end

  # --- Participant Management ---

  @doc """
  Gets the role of a user within a specific space.
  Returns the role atom (:owner, :admin, :member) or nil if not a participant.
  """
  def get_participant_role(%User{id: user_id}, %Space{id: space_id}) do
    Repo.get_by(Participant, user_id: user_id, space_id: space_id)
    |> case do
      %Participant{role: role} -> role
      nil -> nil
    end
  end

  @doc """
  Adds a participant to a space. Requires admin or owner role.
  Defaults to :member role if not specified.
  """
  def add_participant(
        %Scope{user: current_user} = _scope,
        %Space{} = space,
        %User{} = user_to_add,
        role \\ :member
      ) do
    # Check if current_user is admin or owner
    case get_participant_role(current_user, space) do
      :owner -> do_add_participant(space, user_to_add, role)
      :admin -> do_add_participant(space, user_to_add, role)
      _ -> {:error, :unauthorized}
    end
  end

  defp do_add_participant(space, user_to_add, role) do
    %Participant{}
    |> Participant.changeset(%{
      user_id: user_to_add.id,
      space_id: space.id,
      role: role
    })
    |> Repo.insert()
  end

  @doc """
  Removes a participant from a space. Requires owner role.
  Owners cannot remove themselves.
  """
  def remove_participant(
        %Scope{user: current_user} = _scope,
        %Participant{} = participant_to_remove
      ) do
    # Fetch the space to check ownership
    space = Repo.preload(participant_to_remove, :space).space

    # Check if current_user is owner of the space
    case get_participant_role(current_user, space) do
      :owner ->
        # Check if the owner is trying to remove themselves
        if current_user.id == participant_to_remove.user_id do
          {:error, :cannot_remove_self}
        else
          Repo.delete(participant_to_remove)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  # TODO: Add update_participant_role function
  # TODO: Add list_participants function
end
