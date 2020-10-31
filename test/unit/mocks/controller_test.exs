defmodule WarlockTest.Mocks.Controller do
  use ExUnit.Case

  alias Warlock.Mocks.Controller

  test "new/2" do
    assert Controller.new(1, 2) == {:ok, "new"}
  end

  test "get/2" do
    assert Controller.get(1, 2) == {:ok, "get"}
  end

  test "by_id/2" do
    assert Controller.by_id(1, 2) == {:ok, "by_id"}
  end

  test "edit/3" do
    assert Controller.edit(1, 2, 3) == {:ok, "edit"}
  end

  test "delete/2" do
    assert Controller.delete(1, 2) == {:ok, "delete"}
  end
end
