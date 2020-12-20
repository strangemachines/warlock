defmodule WarlockTest.Unit.Schema do
  use ExUnit.Case

  alias Warlock.Schema

  test "pagination_offset/2" do
    assert Schema.pagination_offset("1", "20") == 0
  end

  test "pagination_offset/2 with page > 1" do
    assert Schema.pagination_offset("3", "20") == 40
  end
end
