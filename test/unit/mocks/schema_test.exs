defmodule WarlockTest.Mocks.Schema do
  use ExUnit.Case

  alias Warlock.Mocks.Schema

  test "new/2" do
    assert Schema.new(1, 2) == {:ok, "new"}
  end

  test "get/2" do
    assert Schema.get(1, 2) == ["get"]
  end

  test "by_id/2" do
    assert Schema.by_id(1, 2) == {:ok, "by_id"}
  end

  test "edit/3" do
    assert Schema.edit(1, 2, 3) == {:ok, "edit"}
  end

  test "delete/2" do
    assert Schema.delete(1, 2) == {0, nil}
  end
end
