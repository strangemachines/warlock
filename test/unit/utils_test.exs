defmodule WarlockTest.Utils do
  use ExUnit.Case

  alias Warlock.Utils

  test "get_items/1" do
    conn = %{query_params: %{}}
    assert Utils.get_items(conn) == 20
  end

  test "get_items/1 with items in query" do
    conn = %{query_params: %{"items" => "10"}}
    assert Utils.get_items(conn) == 10
  end

  test "get_page/2" do
    conn = %{query_params: %{}}
    assert Utils.get_page(conn) == 1
  end

  test "get_page/2 with page in query" do
    conn = %{query_params: %{"page" => "2"}}
    assert Utils.get_page(conn) == 2
  end
end
