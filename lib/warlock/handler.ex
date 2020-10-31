defmodule Warlock.Handler do
  alias Warlock.Handler
  alias Warlock.ModuleUtils
  alias Plug.Conn

  @callback get(conn :: Conn.t()) :: Conn.t() | no_return

  @callback new(conn :: Conn.t()) :: Conn.t() | no_return

  @callback show(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback edit(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback delete(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @optional_callbacks get: 1, new: 1, show: 2, edit: 2, delete: 2

  def send_json(conn, status, payload) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(status, Jason.encode!(payload))
  end

  def send_siren(conn, status, payload) do
    conn
    |> Conn.put_resp_content_type("application/vnd.siren+json")
    |> Conn.send_resp(status, Jason.encode!(payload))
  end

  def send_message(conn, status, message) do
    Handler.send_json(conn, status, %{:message => message})
  end

  def send_200(conn, payload), do: Handler.send_json(conn, 200, payload)

  def send_201(conn, payload), do: Handler.send_json(conn, 201, payload)

  def send_204(conn), do: Conn.send_resp(conn, 204, [])

  def send_400(conn, error), do: Handler.send_message(conn, 400, error)
  def send_400(conn), do: Handler.send_message(conn, 400, "Bad request")

  def send_401(conn) do
    conn
    |> Conn.put_resp_header(
      "www-authenticate",
      "Bearer realm=\"authenticate\", error=\"invalid_token\""
    )
    |> Handler.send_message(401, "Your credentials are invalid")
  end

  def send_403(conn) do
    Handler.send_message(conn, 403, "You're not allowed to perform this action")
  end

  def send_404(conn) do
    Handler.send_message(conn, 404, "The requested resource does not exist")
  end

  def send_500(conn) do
    Handler.send_message(conn, 500, "An unknown internal error occured")
  end

  def send_501(conn) do
    Handler.send_message(conn, 501, "This endpoint is not implemented yet")
  end

  defmacro __using__([]) do
    quote do
      alias unquote(ModuleUtils.replace_at(__CALLER__.module, "Controllers"))

      alias Plug.Conn

      import Warlock.Handler

      @behaviour Warlock.Handler
    end
  end
end
