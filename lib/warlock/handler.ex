defmodule Warlock.Handler do
  alias Warlock.Handler
  alias Warlock.ModuleUtils, as: Utils
  alias Plug.Conn

  @callback get(conn :: Conn.t()) :: Conn.t() | no_return

  @callback new(conn :: Conn.t()) :: Conn.t() | no_return

  @callback show(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback edit(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @callback delete(conn :: Conn.t(), id :: String.t()) :: Conn.t() | no_return

  @optional_callbacks get: 1, new: 1, show: 2, edit: 2, delete: 2

  def get_user_kind(conn, auth_kind) do
    if auth_kind == :anyone, do: :anyone, else: conn.private[auth_kind]
  end

  defmacro new_item(controller, auth_kind) do
    quote do
      @impl true
      def new(conn) do
        user = Handler.get_user_kind(conn, unquote(auth_kind))

        case unquote(controller).new(conn.body_params, user) do
          {:ok, item} ->
            unquote(__CALLER__.module).send_201(conn, item)

          {:error, :forbidden} ->
            unquote(__CALLER__.module).send_403(conn)

          {:error, %Ecto.Changeset{} = changeset} ->
            unquote(__CALLER__.module).send_422(conn, changeset,
              class: "input-error"
            )

          {:error, _error} ->
            unquote(__CALLER__.module).send_500(conn)
        end
      end
    end
  end
  defmacro __using__(opts \\ []) do
    quote do
      name = unquote(Utils.name_or_option(__CALLER__.module, opts[:name]))

      alias Plug.Conn
      alias unquote(Utils.replace_at(__CALLER__.module, "Controllers"))

      import Warlock.Handler
      import Warlock.Handler.Builder

      @behaviour Warlock.Handler
      @controller unquote(Utils.replace_at(__CALLER__.module, "Controllers"))

      @auth_challenge Application.compile_env(name, :auth_challenge, "bearer")
      @auth_error Application.compile_env(
                    name,
                    :auth_error,
                    "invalid_credentials"
                  )
      @auth_realm Application.compile_env(name, :auth_realm, name)

      @response_type unquote(opts[:response_type]) ||
                       Application.compile_env(name, :response_type, :json)
      @messages Application.compile_env(name, :default_messages, [])

      @accepted Keyword.get(@messages, :accepted, "accepted")
      @bad_request Keyword.get(@messages, :bad_request, "bad request")
      @unauthorized Keyword.get(@messages, :unauthorized, "unauthorized")
      @forbidden Keyword.get(@messages, :forbidden, "forbidden")
      @not_found Keyword.get(@messages, :not_found, "not found")
      @not_allowed Keyword.get(@messages, :not_allowed, "not allowed")
      @conflict Keyword.get(@messages, :conflict, "conflict")
      @gone Keyword.get(@messages, :gone, "gone")
      @unsupported Keyword.get(@messages, :unsupported, "unsupported")
      @unprocessable Keyword.get(@messages, :unprocessable, "unprocessable")
      @too_many Keyword.get(@messages, :too_many, "too many requests")
      @server_error Keyword.get(@messages, :internal_error, "unknown")
      @not_implemented Keyword.get(
                         @messages,
                         :not_implemented,
                         "not implemented"
                       )

      payload(200, @response_type)
      payload(201, @response_type)
      payload(202, @response_type)
      error(400, @bad_request, @response_type)
      error(403, @forbidden, @response_type)
      error(404, @not_found, @response_type)
      error(405, @not_allowed, @response_type)
      error(409, @conflict, @response_type)
      error(410, @gone, @response_type)
      error(415, @unsupported, @response_type)
      error(422, @unprocessable, @response_type)
      error(429, @too_many, @response_type)
      error(500, @server_error, @response_type)
      error(501, @not_implemented, @response_type)

      if @response_type == :siren do
        build_siren_handler()
      else
        build_json_handler()
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
