defmodule WarlockTest.Siren.Errors do
  use ExUnit.Case
  import Dummy

  alias Warlock.Siren.Errors
  alias Ecto.Changeset

  test "error_type/1" do
    assert Errors.error_type({nil, nil}) == "unknown"
  end

  test "error_type/1 with validation of required" do
    assert Errors.error_type({nil, [validation: :required]}) == "missing-value"
  end

  test "error_type/1 with validation of cast" do
    assert Errors.error_type({nil, [validation: :cast]}) == "invalid-value"
  end

  test "error_type/1 with validation of inclusion" do
    result = Errors.error_type({nil, [validation: :inclusion]})
    assert result == "invalid-value"
  end

  test "error_type/1 with validation of subset" do
    result = Errors.error_type({nil, [validation: :subset]})
    assert result == "invalid-value"
  end

  test "error_type/1 with validation of exclusion" do
    result = Errors.error_type({nil, [validation: :exclusion]})
    assert result == "invalid-value"
  end

  test "error_type/1 with validation of unsafe_unique" do
    result = Errors.error_type({nil, [validation: :unsafe_unique]})
    assert result == "invalid-unique"
  end

  test "error_type/1 with validation of format" do
    result = Errors.error_type({nil, [validation: :format]})
    assert result == "invalid-format"
  end

  test "error_type/1 with validation of length" do
    result = Errors.error_type({nil, [validation: :length]})
    assert result == "invalid-length"
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
