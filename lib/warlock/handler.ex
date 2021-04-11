defmodule Warlock.Handler do
  alias Warlock.{Handler, Siren}
  alias Warlock.ModuleUtils, as: Utils
  alias Plug.Conn

  @callback get(conn :: Conn.t()) :: Conn.t() | no_return

  @callback new(conn :: Conn.t()) :: Conn.t() | no_return

  @callback show(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback edit(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback delete(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @optional_callbacks get: 1, new: 1, show: 2, edit: 2, delete: 2

  defmacro json_payload(code) do
    quote do
      def unquote(:"send_#{code}")(conn, payload) do
        Handler.json(conn, unquote(code), payload)
      end
    end
  end

  defmacro json_error(code, default_error) do
    quote do
      def unquote(:"send_#{code}")(conn) do
        Handler.message(conn, unquote(code), unquote(default_error))
      end

      def unquote(:"send_#{code}")(conn, error) do
        Handler.json(conn, unquote(code), error)
      end
    end
  end

  defmacro siren_payload(code) do
    quote do
      def unquote(:"send_#{code}")(conn, payload) do
        Handler.siren(conn, unquote(code), Siren.encode(conn, payload))
      end

      def unquote(:"send_#{code}")(conn, payload, count)
          when is_number(count) do
        Handler.siren(conn, unquote(code), Siren.encode(conn, payload, count))
      end
    end
  end

  defmacro siren_error(code) do
    quote do
      def unquote(:"send_#{code}")(conn) do
        Handler.siren(conn, unquote(code), Siren.error(unquote(code)))
      end

      def unquote(:"send_#{code}")(conn, error) do
        Handler.siren(conn, unquote(code), Siren.error(unquote(code), error))
      end
    end
  end

  def json(conn, status, payload) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(status, Jason.encode!(payload))
  end

  def siren(conn, status, payload) do
    conn
    |> Conn.put_resp_content_type("application/vnd.siren+json")
    |> Conn.send_resp(status, Jason.encode!(payload))
  end

  def message(conn, status, message) do
    Handler.json(conn, status, %{:message => message})
  end

  defmacro __using__(opts \\ []) do
    quote do
      name = unquote(opts[:name]) || unquote(Utils.atom_name(__CALLER__.module))

      alias Plug.Conn
      alias Warlock.Siren
      alias unquote(Utils.replace_at(__CALLER__.module, "Controllers"))

      import Warlock.Handler

      @behaviour Warlock.Handler

      @auth_challenge Application.get_env(name, :auth_challenge, "bearer")
      @auth_error Application.get_env(name, :auth_error, "invalid_credentials")
      @auth_realm Application.get_env(name, :auth_realm, name)

      @response_type unquote(opts[:response_type]) ||
                       Application.get_env(name, :response_type, :json)
      @messages Application.get_env(name, :default_messages, [])

      @accepted Keyword.get(@messages, :accepted, "accepted")
      @bad_request Keyword.get(@messages, :bad_request, "bad request")
      @unauthorized Keyword.get(@messages, :unauthorized, "unauthorized")
      @forbidden Keyword.get(@messages, :forbidden, "forbidden")
      @not_found Keyword.get(@messages, :not_found, "not found")
      @not_allowed Keyword.get(@messages, :not_allowed, "not allowed")
      @conflict Keyword.get(@messages, :conflict, "conflict")
      @unsupported Keyword.get(@messages, :unsupported, "unsupported")
      @unprocessable Keyword.get(@messages, :unprocessable, "unprocessable")
      @server_error Keyword.get(@messages, :internal_error, "unknown")
      @not_implemented Keyword.get(
                         @messages,
                         :not_implemented,
                         "not implemented"
                       )

      if @response_type == :siren do
        siren_payload(200)
        siren_payload(201)
        siren_payload(202)
        siren_error(400)
        siren_error(403)
        siren_error(404)
        siren_error(405)
        siren_error(409)
        siren_error(415)
        siren_error(422)
        siren_error(500)
        siren_error(501)

        def send_202(conn) do
          Handler.siren(conn, 202, Siren.message(202, @accepted))
        end

        def send_401(conn) do
          conn
          |> unquote(__CALLER__.module).authenticate()
          |> Handler.siren(401, Siren.error(401))
        end

        def send_401(conn, error) do
          conn
          |> unquote(__CALLER__.module).authenticate()
          |> Handler.siren(401, Siren.error(401, error))
        end
      else
        json_payload(200)
        json_payload(201)
        json_payload(202)
        json_error(400, @bad_request)
        json_error(403, @forbidden)
        json_error(404, @not_found)
        json_error(405, @not_allowed)
        json_error(409, @conflict)
        json_error(415, @unsupported)
        json_error(422, @unprocessable)
        json_error(500, @server_error)
        json_error(501, @not_implemented)

        def send_202(conn), do: Handler.message(conn, 202, @accepted)

        def send_401(conn) do
          conn
          |> unquote(__CALLER__.module).authenticate()
          |> Handler.message(401, @unauthorized)
        end

        def send_401(conn, error) do
          conn
          |> unquote(__CALLER__.module).authenticate()
          |> Handler.json(401, error)
        end
      end

      def authenticate(conn) do
        Conn.put_resp_header(
          conn,
          "www-authenticate",
          "#{@auth_challenge} realm=\"#{@auth_realm}\", error=\"#{@auth_error}\""
        )
      end

      def send_204(conn), do: Conn.send_resp(conn, 204, [])
    end
  end
end
