defmodule WarlockTest.Siren.Errors do
  use ExUnit.Case
  import Dummy

  alias Warlock.Siren.Errors
  alias Ecto.Changeset

  test "error_type/1" do
    assert Errors.error_type({nil, nil}) == "unknown"
  end

  test "error_type/1 with validationrequired" do
    assert Errors.error_type({nil, [validation: :required]}) == "missing-value"
  end

  test "error_type/1 with validation cast" do
    assert Errors.error_type({nil, [validation: :cast]}) == "invalid-value"
  end

  test "parse/1" do
    assert Errors.parse("errors") == "errors"
  end

  test "parse/1 with a changeset" do
    dummy Errors, [{"error_type", :type}] do
      result = Errors.parse(%Changeset{errors: %{key: {"value"}}})
      assert result == [%{field: :key, message: "value", type: :type}]
      assert called(Errors.error_type({"value"}))
    end
  end
end
