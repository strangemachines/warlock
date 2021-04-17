defmodule WarlockTest.Integration.Mocks.SirenHandler do
  use ExUnit.Case

  import Dummy

  alias Warlock.{Handler, Siren}
  alias Warlock.Mocks.SirenHandler

  @payload_codes [200, 201, 202]

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
    dummy Siren, [{"encode/2", :encoded}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.get(:conn) == :siren
        assert called(Siren.encode(:conn, :payload))
        assert called(Handler.siren(:conn, 200, :encoded))
      end
    end
  end

  test "get/2 with send_200/2" do
    dummy Siren, [{"encode/3", :encoded}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.get(:conn, 25) == :siren
        assert called(Siren.encode(:conn, :payload, 25))
        assert called(Handler.siren(:conn, 200, :encoded))
      end
    end
  end

  test "new/1 with send_200/2" do
    dummy Siren, [{"encode/2", :encoded}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.new(:conn) == :siren
        assert called(Siren.encode(:conn, :payload))
        assert called(Handler.siren(:conn, 201, :encoded))
      end
    end
  end

  test "send_202/1" do
    dummy Siren, [{"message/2", :message}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_202(:conn) == :siren
        assert called(Siren.message(202, "accepted"))
        assert called(Handler.siren(:conn, 202, :message))
      end
    end
  end

  test "send_202/2" do
    dummy Siren, [{"encode/2", :encoded}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_202(:conn, :payload) == :siren
        assert called(Siren.encode(:conn, :payload))
        assert called(Handler.siren(:conn, 202, :encoded))
      end
    end
  end

  for code <- @payload_codes do
    test "send_#{code}/3" do
      dummy Siren, [{"encode/3", :encoded}] do
        dummy Handler, [{"siren/3", :siren}] do
          assert SirenHandler.unquote(:"send_#{code}")(:conn, :payload, :count) ==
                   :siren

          assert called(Siren.encode(:conn, :payload, :count))
          assert called(Handler.siren(:conn, unquote(code), :encoded))
        end
      end
    end
  end

  for code <- [400, 403, 404, 405, 409, 415, 422, 500, 501] do
    test "send_#{code}/1" do
      text = @messages_map[unquote(code)]
      opts = [class: ["error", text], summary: text]

      dummy Siren, [{"error/3", :err}] do
        dummy Handler, [{"siren/3", :siren}] do
          assert SirenHandler.unquote(:"send_#{code}")(:conn) == :siren
          assert called(Siren.error(unquote(code), [], opts))
          assert called(Handler.siren(:conn, unquote(code), :err))
        end
      end
    end
  end

  for code <- [400, 403, 404, 405, 409, 415, 422, 500, 501] do
    test "send_#{code}/2" do
      text = @messages_map[unquote(code)]
      opts = [class: ["error", text], summary: text]

      dummy Siren, [{"error/3", :err}] do
        dummy Handler, [{"siren/3", :siren}] do
          assert SirenHandler.unquote(:"send_#{code}")(:conn, :error) == :siren
          assert called(Siren.error(unquote(code), :error, opts))
          assert called(Handler.siren(:conn, unquote(code), :err))
        end
      end
    end
  end

  for code <- [400, 403, 404, 405, 409, 415, 422, 500, 501] do
    test "send_#{code}/3" do
      dummy Siren, [{"error/3", :err}] do
        dummy Handler, [{"siren/3", :siren}] do
          assert SirenHandler.unquote(:"send_#{code}")(:conn, :error, :opts) ==
                   :siren

          assert called(Siren.error(unquote(code), :error, :opts))
          assert called(Handler.siren(:conn, unquote(code), :err))
        end
      end
    end
  end

  test "send_401/1" do
    text = @messages_map[401]
    opts = [class: ["error", text], summary: text]

    dummy Siren, [{"error/3", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        dummy SirenHandler, [{"authenticate", :auth}] do
          assert SirenHandler.send_401(:conn) == :siren
          assert called(SirenHandler.authenticate(:conn))
          assert called(Siren.error(401, [], opts))
          assert called(Handler.siren(:auth, 401, :err))
        end
      end
    end
  end

  test "send_401/2" do
    text = @messages_map[401]
    opts = [class: ["error", text], summary: text]

    dummy Siren, [{"error/3", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        dummy SirenHandler, [{"authenticate", :auth}] do
          assert SirenHandler.send_401(:conn, :error) == :siren
          assert called(SirenHandler.authenticate(:conn))
          assert called(Siren.error(401, :error, opts))
          assert called(Handler.siren(:auth, 401, :err))
        end
      end
    end
  end
end
