defmodule WarlockTest.Unit.Mocks.JsonHandler do
  use ExUnit.Case

  import Dummy

  alias Plug.Conn
  alias Warlock.Mocks.JsonHandler

  test "authenticate/1" do
    value = "bearer realm=\"warlock\", error=\"invalid_credentials\""

    dummy Conn, [{"put_resp_header/3", :resp_header}] do
      assert JsonHandler.authenticate(:conn) == :resp_header
      assert called(Conn.put_resp_header(:conn, "www-authenticate", value))
    end
  end

  test "new/1" do
    dummy JsonHandler, [{"send_201/2", 201}] do
      assert JsonHandler.new(:conn) == 201
      assert called(JsonHandler.send_201(:conn, :payload))
    end
  end

  test "get/1" do
    dummy JsonHandler, [{"send_200/2", 200}] do
      assert JsonHandler.get(:conn) == 200
      assert called(JsonHandler.send_200(:conn, :payload))
    end
  end

  test "show/2" do
    assert JsonHandler.show("conn", "id") == "conn"
  end

  test "edit/3" do
    assert JsonHandler.edit("conn", "id") == "conn"
  end

  test "delete/2" do
    dummy JsonHandler, [{"send_204", 204}] do
      assert JsonHandler.delete(:conn, :id) == 204
      assert called(JsonHandler.send_204(:conn))
    end
  end
end
