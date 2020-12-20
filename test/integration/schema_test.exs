defmodule WarlockTest.Integration.Schema do
  use ExUnit.Case
  import Dummy

  alias Ecto.Changeset
  alias Warlock.Mocks.{Repo, Schema}

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

  test "set_user/2" do
    assert Schema.set_user(:changeset, nil) == :changeset
  end

  test "create/2" do
    dummy Repo, [{"insert", :insert}] do
      dummy Schema, [{"set_user/2", :set_user}, {"changeset/2", :changeset}] do
        result = Schema.create(:user_id, :payload)
        assert called(Schema.set_user(%Schema{}, :user_id))
        assert called(Schema.changeset(:set_user, :payload))
        assert called(Repo.insert(:changeset))
        assert result == :insert
      end
    end
  end
end
