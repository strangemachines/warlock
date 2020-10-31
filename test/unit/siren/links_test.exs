defmodule WarlockTest.Siren.Links do
  use ExUnit.Case
  import Dummy

  alias Warlock.Siren.Links
  alias Warlock.Utils
  alias Plug.Conn

  test "parse_uri/1" do
    dummy Conn, [{"request_url", :url}] do
      dummy URI, [{"parse", :parsed}] do
        assert Links.parse_uri(:conn) == :parsed
        assert called(Conn.request_url(:conn))
        assert called(URI.parse(:url))
      end
    end
  end

  test "decode_query/1" do
    dummy URI, [{"decode_query", :query}] do
      assert Links.decode_query(%{query: "x=value"}) == :query
      assert called(URI.decode_query("x=value"))
    end
  end

  test "decode_query/1 when the url has none" do
    assert Links.decode_query(%{query: nil}) == %{}
  end

  test "make/2" do
    assert Links.make("type", "href") == %{rel: ["type"], href: "href"}
  end

  test "change_page/2" do
    url = %{query: "page=1"}

    dummy URI, [{"encode_query", "query"}, {"to_string", :string}] do
      dummy Links, [{"parse_uri", url}, {"decode_query", %{}}] do
        assert Links.change_page(:conn, 2) == :string
        assert called(Links.parse_uri(:conn))
        assert called(Links.decode_query(url))
        assert called(URI.encode_query(%{"page" => 2}))
        assert called(URI.to_string(%{query: "query"}))
      end
    end
  end

  test "add_next/3" do
    dummy Utils, [{"get_page", 2}, {"get_items", 20}] do
      dummy Links, [{"change_page/2", :page}, {"make/2", :link}] do
        assert Links.add_next([], :conn, 100) == [:link]
        assert called(Utils.get_page(:conn))
        assert called(Utils.get_items(:conn))
        assert called(Links.change_page(:conn, 3))
        assert called(Links.make("next", :page))
      end
    end
  end

  test "add_next/3 with items * page > count" do
    dummy Utils, [{"get_page", 1}, {"get_items", 200}] do
      assert Links.add_next([], :conn, 100) == []
    end
  end

  test "add_next/3 on last page" do
    dummy Utils, [{"get_page", 5}, {"get_items", 20}] do
      assert Links.add_next([], :conn, 100) == []
    end
  end

  test "add_last/3" do
    conn = %{query_params: %{}}

    dummy Utils, [{"get_items", 20}] do
      dummy Links, [{"change_page/2", :page}, {"make/2", :link}] do
        assert Links.add_last([], conn, 40) == [:link]
        assert called(Utils.get_items(conn))
        assert called(Links.change_page(conn, 2))
        assert called(Links.make("last", :page))
      end
    end
  end

  test "add_prev/2" do
    conn = %{query_params: %{"page" => "2"}}

    dummy Links, [{"change_page/2", :page}, {"make/2", :link}] do
      assert Links.add_prev([], conn) == [:link]
      assert called(Links.change_page(conn, 1))
      assert called(Links.make("prev", :page))
    end
  end

  test "add_prev/2 on the first page" do
    assert Links.add_prev([], %{query_params: %{"page" => "1"}}) == []
  end

  test "add_prev/2 without a page" do
    assert Links.add_prev([], %{query_params: %{}}) == []
  end

  test "add_self/2" do
    dummy Conn, [{"request_url", :url}] do
      dummy Links, [{"make/2", :link}] do
        assert Links.add_self([], :conn) == [:link]
        assert called(Links.make("self", :url))
      end
    end
  end

  test "add_first/2" do
    dummy Links, [{"change_page/2", :page}, {"make/2", :link}] do
      assert Links.add_first([], :conn) == [:link]
      assert called(Links.change_page(:conn, 1))
      assert called(Links.make("first", :page))
    end
  end
end
