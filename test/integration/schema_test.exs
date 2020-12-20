defmodule WarlockTest.Integration.Schema do
  use ExUnit.Case
  import Dummy

  alias Ecto.Changeset
  alias Warlock.Mocks.Schema

  test "validate_fields/1" do
    assert Schema.validate_fields(:item) == :item
  end

  test "changeset/2" do
    dummy Changeset, [{"cast/3", :cast}, {"validate_required/2", :required}] do
      dummy Schema, [{"validate_fields/1", :fields}] do
        result = Schema.changeset(:item, :payload)
        assert called(Changeset.cast(:item, :payload, :public_fields))
        assert called(Changeset.validate_required(:cast, :required_fields))
        assert called(Schema.validate_fields(:required))
        assert result == :fields
      end
    end
  end
end
