defmodule Errly.SpacesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Errly.Spaces` context.
  """

  @doc """
  Generate a space.
  """
  def space_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        slug: "some slug"
      })

    {:ok, space} = Errly.Spaces.create_space(scope, attrs)
    space
  end
end
