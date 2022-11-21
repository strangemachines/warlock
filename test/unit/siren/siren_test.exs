defmodule WarlockTest.Siren do
  use ExUnit.Case
  import Dummy

  alias Warlock.Siren
  alias Warlock.Siren.{Errors, Links}

  test "links/2" do
    dummy Links, [
      {"add_self/2", :self},
      {"add_prev/2", :prev},
      {"add_first/2", :first},
      {"add_next/3", :next},
      {"add_last/3", :last}
    ] do
      assert Siren.links(:conn, :count) == :last
      assert Links.add_self([], :conn)
      assert called(Links.add_prev(:self, :conn))
      assert called(Links.add_first(:prev, :conn))
      assert called(Links.add_next(:first, :conn, :count))
      assert called(Links.add_last(:next, :conn, :count))
    end
  end

  test "encode/3" do
    expected = %{
      properties: %{items: :count},
      entities: :payload,
      links: :links
    }

    dummy Siren, [{"links/2", :links}] do
      assert Siren.encode(:conn, :payload, :count) == expected
      assert called(Siren.links(:conn, :count))
    end
  end

  test "encode/2" do
    expected = %{properties: :payload, links: [:self]}

    dummy Links, [{"add_self/2", [:self]}] do
      assert Siren.encode(:conn, :payload) == expected
      assert called(Links.add_self([], :conn))
    end
  end

  test "message/2" do
    expected = %{properties: %{code: :code, summary: :message}}
    assert Siren.message(:code, :message) == expected
  end

  test "error/2" do
    dummy Errors, [{"parse", :parse}] do
      result = Siren.error(:code, :errors)
      assert result[:class] == ["error", "unknown"]
      assert result[:properties][:code] == :code
      assert result[:properties][:summary] == "unknown error"
      assert result[:properties][:errors] == :parse
      assert called(Errors.parse(:errors))
    end
  end

  test "error/3 with class option" do
    dummy Errors, [{"parse", :parse}] do
      result = Siren.error(:code, :errors, class: ["custom"])
      assert result[:class] == ["custom"]
    end
  end

  test "error/3 with summary option" do
    dummy Errors, [{"parse", :parse}] do
      result = Siren.error(:code, :errors, summary: "custom")
      assert result[:properties][:summary] == "custom"
    end
  end
end
