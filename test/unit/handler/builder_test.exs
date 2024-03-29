defmodule WarlockTest.Unit.Handler.Builder do
  use ExUnit.Case

  alias Warlock.Handler.Builder
  alias Plug.Conn

  import Dummy

  test "json/3" do
    dummy Conn, [{"send_resp/3", :resp}, {"put_resp_content_type/2", :type}] do
      dummy Jason, [{"encode!", :json}] do
        assert Builder.json(:conn, 200, %{}) == :resp
        assert called(Conn.put_resp_content_type(:conn, "application/json"))
        assert called(Jason.encode!(%{}))
        assert called(Conn.send_resp(:type, 200, :json))
      end
    end
  end

  test "siren/3" do
    siren = "application/vnd.siren+json"

    dummy Conn, [{"send_resp/3", :resp}, {"put_resp_content_type/2", :type}] do
      dummy Jason, [{"encode!", :json}] do
        assert Builder.siren(:conn, 200, %{}) == :resp
        assert called(Conn.put_resp_content_type(:conn, siren))
        assert called(Jason.encode!(%{}))
        assert called(Conn.send_resp(:type, 200, :json))
      end
    end
  end

  test "message/3" do
    dummy Builder, [{"json/3", :json}] do
      assert Builder.message(:conn, 200, "hello") == :json
      assert called(Builder.json(:conn, 200, %{:message => "hello"}))
    end
  end
end
