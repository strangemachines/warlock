defmodule WarlockTest.Controller do
  use ExUnit.Case

  alias Warlock.Controller

  test "list_to_outcome/1" do
    assert Controller.list_to_outcome([:item]) == {:ok, :item}
  end

  test "list_to_outcome/1 with an empty list" do
    assert Controller.list_to_outcome([]) == {:error, :not_found}
  end

  test "list_to_outcome/1 with multiple items" do
    result = Controller.list_to_outcome([:item, :item])
    assert result == {:error, :too_many_items}
  end
end
