defmodule WarlockTest.Integration.Mocks.SirenHandler do
  use ExUnit.Case

  import Dummy

  alias Warlock.{Handler, Siren}
  alias Warlock.Mocks.SirenHandler

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
    payload = "The request has been accepted"

    dummy Siren, [{"message/2", :message}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_202(:conn) == :siren
        assert called(Siren.message(202, payload))
        assert called(Handler.siren(:conn, 202, :message))
      end
    end
  end

  test " send_202/2" do
    dummy Siren, [{"encode/2", :encoded}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_202(:conn, :payload) == :siren
        assert called(Siren.encode(:conn, :payload))
        assert called(Handler.siren(:conn, 202, :encoded))
      end
    end
  end

  test "send_400/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_400(:conn) == :siren
        assert called(Siren.error(400))
        assert called(Handler.siren(:conn, 400, :err))
      end
    end
  end

  for code <- [400, 403, 404, 405, 409, 415, 422, 500, 501] do
    test "send_#{code}/2" do
      dummy Siren, [{"error/2", :err}] do
        dummy Handler, [{"siren/3", :siren}] do
          assert SirenHandler.unquote(:"send_#{code}")(:conn, :error) == :siren
          assert called(Siren.error(unquote(code), :error))
          assert called(Handler.siren(:conn, unquote(code), :err))
        end
      end
    end
  end

  test "send_401/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        dummy SirenHandler, [{"authenticate", :auth}] do
          assert SirenHandler.send_401(:conn) == :siren
          assert called(SirenHandler.authenticate(:conn))
          assert called(Siren.error(401))
          assert called(Handler.siren(:auth, 401, :err))
        end
      end
    end
  end

  test "send_401/2" do
    dummy Siren, [{"error/2", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        dummy SirenHandler, [{"authenticate", :auth}] do
          assert SirenHandler.send_401(:conn, :error) == :siren
          assert called(SirenHandler.authenticate(:conn))
          assert called(Siren.error(401, :error))
          assert called(Handler.siren(:auth, 401, :err))
        end
      end
    end
  end

  test "send_403/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_403(:conn) == :siren
        assert called(Siren.error(403))
        assert called(Handler.siren(:conn, 403, :err))
      end
    end
  end

  test "send_404/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_404(:conn) == :siren
        assert called(Siren.error(404))
        assert called(Handler.siren(:conn, 404, :err))
      end
    end
  end

  test "send_405/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_405(:conn) == :siren
        assert called(Siren.error(405))
        assert called(Handler.siren(:conn, 405, :err))
      end
    end
  end

  test "send_409/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_409(:conn) == :siren
        assert called(Siren.error(409))
        assert called(Handler.siren(:conn, 409, :err))
      end
    end
  end

  test "send_415/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_415(:conn) == :siren
        assert called(Siren.error(415))
        assert called(Handler.siren(:conn, 415, :err))
      end
    end
  end

  test "send_422/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_422(:conn) == :siren
        assert called(Siren.error(422))
        assert called(Handler.siren(:conn, 422, :err))
      end
    end
  end

  test "send_500/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_500(:conn) == :siren
        assert called(Siren.error(500))
        assert called(Handler.siren(:conn, 500, :err))
      end
    end
  end

  test "send_501/1" do
    dummy Siren, [{"error", :err}] do
      dummy Handler, [{"siren/3", :siren}] do
        assert SirenHandler.send_501(:conn) == :siren
        assert called(Siren.error(501))
        assert called(Handler.siren(:conn, 501, :err))
      end
    end
  end
end
