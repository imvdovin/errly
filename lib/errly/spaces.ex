defmodule Errly.Spaces do
  @moduledoc """
  The Spaces context.
  """

  import Ecto.Query, warn: false
  alias Errly.Repo

  alias Errly.Spaces.Space
  alias Errly.Accounts.Scope
  alias Errly.Spaces.Participant

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
  Returns the list of spaces.

  ## Examples

      iex> list_spaces(scope)
      [%Space{}, ...]

  """
  def list_spaces(%Scope{} = scope) do
    Repo.all(from space in Space, where: space.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single space.

  Raises `Ecto.NoResultsError` if the Space does not exist.

  ## Examples

      iex> get_space!(123)
      %Space{}

      iex> get_space!(456)
      ** (Ecto.NoResultsError)

  """
  def get_space!(%Scope{} = scope, id) do
    Repo.get_by!(Space, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a space.

  ## Examples

      iex> create_space(%{field: value})
      {:ok, %Space{}}

      iex> create_space(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_space(%Scope{} = scope, attrs) do
    with {:ok, space = %Space{}} <-
           %Space{}
           |> Space.changeset(attrs)
           |> Repo.insert() do
      broadcast(scope, {:created, space})
      {:ok, space}
    end
  end

  @doc """
  Updates a space.

  ## Examples

      iex> update_space(space, %{field: new_value})
      {:ok, %Space{}}

      iex> update_space(space, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_space(%Scope{} = scope, %Space{} = space, attrs) do
    with {:ok, space = %Space{}} <-
           space
           |> Space.changeset(attrs)
           |> Repo.update() do
      broadcast(scope, {:updated, space})
      {:ok, space}
    end
  end

  @doc """
  Deletes a space.

  ## Examples

      iex> delete_space(space)
      {:ok, %Space{}}

      iex> delete_space(space)
      {:error, %Ecto.Changeset{}}

  """
  def delete_space(%Scope{} = scope, %Space{} = space) do
    with {:ok, space = %Space{}} <-
           Repo.delete(space) do
      broadcast(scope, {:deleted, space})
      {:ok, space}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking space changes.

  ## Examples

      iex> change_space(space)
      %Ecto.Changeset{data: %Space{}}

  """
  def change_space(%Scope{} = _scope, %Space{} = space, attrs \\ %{}) do
    Space.changeset(space, attrs)
  end
end
