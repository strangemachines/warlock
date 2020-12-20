defmodule WarlockTest.Unit.Mocks.Repo do
  use ExUnit.Case

  alias Warlock.Mocks.Repo

  test "insert/1" do
    assert Repo.insert(:changeset) == {:ok, :changeset}
  end
end
