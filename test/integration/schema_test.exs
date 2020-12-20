defmodule WarlockTest.Integration.Schema do
  use ExUnit.Case

  alias Warlock.Mocks.Schema

  test "validate_fields/1" do
    assert Schema.validate_fields(:item) == :item
  end
end
