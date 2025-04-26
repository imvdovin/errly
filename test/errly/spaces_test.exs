defmodule Errly.SpacesTest do
  use Errly.DataCase

  alias Errly.Spaces

  describe "spaces" do
    alias Errly.Spaces.Space

    import Errly.AccountsFixtures, only: [user_scope_fixture: 0]
    import Errly.SpacesFixtures

    @invalid_attrs %{name: nil, slug: nil}

    test "list_spaces/1 returns all scoped spaces" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      space = space_fixture(scope)
      other_space = space_fixture(other_scope)
      assert Spaces.list_spaces(scope) == [space]
      assert Spaces.list_spaces(other_scope) == [other_space]
    end

    test "get_space!/2 returns the space with given id" do
      scope = user_scope_fixture()
      space = space_fixture(scope)
      other_scope = user_scope_fixture()
      assert Spaces.get_space!(scope, space.id) == space
      assert_raise Ecto.NoResultsError, fn -> Spaces.get_space!(other_scope, space.id) end
    end

    test "create_space/2 with valid data creates a space" do
      valid_attrs = %{name: "some name", slug: "some slug"}
      scope = user_scope_fixture()

      assert {:ok, %Space{} = space} = Spaces.create_space(scope, valid_attrs)
      assert space.name == "some name"
      assert space.slug == "some slug"
      assert space.user_id == scope.user.id
    end

    test "create_space/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Spaces.create_space(scope, @invalid_attrs)
    end

    test "update_space/3 with valid data updates the space" do
      scope = user_scope_fixture()
      space = space_fixture(scope)
      update_attrs = %{name: "some updated name", slug: "some updated slug"}

      assert {:ok, %Space{} = space} = Spaces.update_space(scope, space, update_attrs)
      assert space.name == "some updated name"
      assert space.slug == "some updated slug"
    end

    test "update_space/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      space = space_fixture(scope)

      assert_raise MatchError, fn ->
        Spaces.update_space(other_scope, space, %{})
      end
    end

    test "update_space/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      space = space_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Spaces.update_space(scope, space, @invalid_attrs)
      assert space == Spaces.get_space!(scope, space.id)
    end

    test "delete_space/2 deletes the space" do
      scope = user_scope_fixture()
      space = space_fixture(scope)
      assert {:ok, %Space{}} = Spaces.delete_space(scope, space)
      assert_raise Ecto.NoResultsError, fn -> Spaces.get_space!(scope, space.id) end
    end

    test "delete_space/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      space = space_fixture(scope)
      assert_raise MatchError, fn -> Spaces.delete_space(other_scope, space) end
    end

    test "change_space/2 returns a space changeset" do
      scope = user_scope_fixture()
      space = space_fixture(scope)
      assert %Ecto.Changeset{} = Spaces.change_space(scope, space)
    end
  end
end
