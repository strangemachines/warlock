defmodule WarlockTest.Integration.Mocks.JsonHandler do
  use ExUnit.Case

  import Dummy

  alias Warlock.Handler
  alias Warlock.Mocks.JsonHandler

  @payload_codes [200, 201, 202]
  @error_codes [400, 403, 404, 405, 409, 415, 422, 500, 501]

  @messages_map %{
    400 => "bad request",
    401 => "unauthorized",
    403 => "forbidden",
    404 => "not found",
    405 => "not allowed",
    409 => "conflict",
    415 => "unsupported",
    422 => "unprocessable",
    500 => "unknown",
    501 => "not implemented"
  }

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
    dummy Handler, [{"message/3", :message}] do
      assert JsonHandler.send_202(:conn) == :message
      assert called(Handler.message(:conn, 202, "accepted"))
    end
  end

  for code <- @payload_codes do
    test "send_#{code}/2" do
      dummy Handler, [{"json/3", :json}] do
        assert JsonHandler.unquote(:"send_#{code}")(:conn, :payload) == :json
        assert called(Handler.json(:conn, unquote(code), :payload))
      end
    end
  end

  for code <- @error_codes do
    test "send_#{code}/1" do
      text = @messages_map[unquote(code)]

      dummy Handler, [{"message/3", :message}] do
        assert JsonHandler.unquote(:"send_#{code}")(:conn) == :message
        assert called(Handler.message(:conn, unquote(code), text))
      end
    end
  end

  for code <- @error_codes do
    test "send_#{code}/2" do
      dummy Handler, [{"json/3", :json}] do
        assert JsonHandler.unquote(:"send_#{code}")(:conn, :error) == :json
        assert called(Handler.json(:conn, unquote(code), :error))
      end
    end
  end

  test "send_401/1" do
    dummy Handler, [{"message/3", :message}] do
      dummy JsonHandler, [{"authenticate", :authenticate}] do
        assert JsonHandler.send_401(:conn) == :message
        assert called(JsonHandler.authenticate(:conn))
        assert called(Handler.message(:authenticate, 401, "unauthorized"))
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
end
