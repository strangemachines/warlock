defmodule WarlockTest.Mocks.Handler do
  use ExUnit.Case

  alias Warlock.Mocks.Handler

  test "new/1" do
    assert Handler.new("conn") == "conn"
  end

  test "get/1" do
    assert Handler.get("conn") == "conn"
  end

  test "show/2" do
    assert Handler.show("conn", "id") == "conn"
  end

  test "edit/3" do
    assert Handler.edit("conn", "id") == "conn"
  end

  test "delete/2" do
    assert Handler.delete("conn", "id") == "conn"
  end
end
