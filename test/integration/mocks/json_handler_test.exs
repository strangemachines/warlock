defmodule WarlockTest.Integration.Mocks.JsonHandler do
  use ExUnit.Case

  import Dummy

  alias Warlock.Handler
  alias Warlock.Mocks.JsonHandler

  test "get/1 with send_200/2" do
    dummy Handler, [{"json/3", :json}] do
      assert JsonHandler.get(:conn) == :json
      assert called(Handler.json(:conn, 200, :payload))
    end
  end

  test "new/1 with send_201/2" do
    dummy Handler, [{"json/3", :json}] do
      assert JsonHandler.new(:conn) == :json
      assert called(Handler.json(:conn, 201, :payload))
    end
  end

  test "delete/2 with send_204/1" do
    dummy Plug.Conn, [{"send_resp/3", :resp}] do
      assert JsonHandler.delete(:conn, :id) == :resp
      assert called(Plug.Conn.send_resp(:conn, 204, []))
    end
  end

  test "send_202/1" do
    payload = "The request has been accepted"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_202(:conn) == :message
      assert called(Handler.message(:conn, 202, payload))
    end
  end

  test "send_202/2" do
    dummy Handler, [{"json/3", :json}] do
      assert JsonHandler.send_202(:conn, :payload) == :json
      assert called(Handler.json(:conn, 202, :payload))
    end
  end

  test "send_400/1" do
    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_400(:conn) == :message
      assert called(Handler.message(:conn, 400, "Bad request"))
    end
  end

  for code <- [400, 403, 404, 405, 409, 415, 422, 500, 501] do
    test "send_#{code}/2" do
      dummy Handler, [{"json/3", :json}] do
        assert JsonHandler.unquote(:"send_#{code}")(:conn, :error) == :json
        assert called(Handler.json(:conn, unquote(code), :error))
      end
    end
  end

  test "send_401/1" do
    value = "Your credentials are invalid"

    dummy Handler, [{"message/3", :message}] do
      dummy JsonHandler, [{"authenticate", :authenticate}] do
        assert JsonHandler.send_401(:conn) == :message
        assert called(JsonHandler.authenticate(:conn))
        assert called(Handler.message(:authenticate, 401, value))
      end
    end
  end

  test "send_401/2" do
    dummy Handler, [{"json/3", :json}] do
      dummy JsonHandler, [{"authenticate", :authenticate}] do
        assert JsonHandler.send_401(:conn, :error) == :json
        assert called(JsonHandler.authenticate(:conn))
        assert called(Handler.json(:authenticate, 401, :error))
      end
    end
  end

  test "send_403/1" do
    value = "You're not allowed to perform this action"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_403(:conn) == :message
      assert called(Handler.message(:conn, 403, value))
    end
  end

  test "send_404/1" do
    value = "The requested resource does not exist"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_404(:conn) == :message
      assert called(Handler.message(:conn, 404, value))
    end
  end

  test "send_405/1" do
    value = "This method is not allowed here"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_405(:conn) == :message
      assert called(Handler.message(:conn, 405, value))
    end
  end

  test "send_409/1" do
    value = "This request would result in a conflict"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_409(:conn) == :message
      assert called(Handler.message(:conn, 409, value))
    end
  end

  test "send_415/1" do
    value = "This media type is unsupported"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_415(:conn) == :message
      assert called(Handler.message(:conn, 415, value))
    end
  end

  test "send_422/1" do
    value = "Unable to process this request"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_422(:conn) == :message
      assert called(Handler.message(:conn, 422, value))
    end
  end

  test "send_500/1" do
    value = "An unknown internal error occured"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_500(:conn) == :message
      assert called(Handler.message(:conn, 500, value))
    end
  end

  test "send_501/1" do
    value = "This endpoint has not been implemented yet"

    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_501(:conn) == :message
      assert called(Handler.message(:conn, 501, value))
    end
  end
end
