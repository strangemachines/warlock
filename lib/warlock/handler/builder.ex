defmodule Warlock.Handler.Builder do
  @doc """
  The builder can be used to create handlers. It's used to build the default
  handler as well.
  """
  alias Plug.Conn
  alias Warlock.Handler.Builder
  alias Warlock.Siren

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
    Builder.json(conn, status, %{:message => message})
  end

  defmacro json_payload(code) do
    quote do
      def unquote(:"send_#{code}")(conn, payload) do
        Builder.json(conn, unquote(code), payload)
      end
    end
  end

  defmacro json_error(code, default_error) do
    quote do
      def unquote(:"send_#{code}")(conn) do
        Builder.message(conn, unquote(code), unquote(default_error))
      end

      def unquote(:"send_#{code}")(conn, error, _opts) do
        Builder.json(conn, unquote(code), error)
      end
    end
  end

  defmacro siren_payload(code) do
    quote do
      def unquote(:"send_#{code}")(conn, payload) do
        Builder.siren(conn, unquote(code), Siren.encode(conn, payload))
      end

      def unquote(:"send_#{code}")(conn, payload, count) do
        Builder.siren(conn, unquote(code), Siren.encode(conn, payload, count))
      end
    end
  end

  defmacro siren_error(code, default_error) do
    quote do
      def unquote(:"send_#{code}")(conn) do
        error =
          Siren.error(unquote(code), [],
            class: ["error", unquote(default_error)],
            summary: unquote(default_error)
          )

        Builder.siren(conn, unquote(code), error)
      end

      def unquote(:"send_#{code}")(conn, error) do
        siren_error =
          Siren.error(unquote(code), error,
            class: ["error", unquote(default_error)],
            summary: unquote(default_error)
          )

        Builder.siren(conn, unquote(code), siren_error)
      end

      def unquote(:"send_#{code}")(conn, error, opts) do
        siren_error = Siren.error(unquote(code), error, opts)
        Builder.siren(conn, unquote(code), siren_error)
      end
    end
  end

  defmacro payload(code, response_type) do
    quote do
      if unquote(response_type) == :siren do
        siren_payload(unquote(code))
      else
        json_payload(unquote(code))
      end
    end
  end

  defmacro error(code, default_error, response_type) do
    quote do
      if unquote(response_type) == :siren do
        siren_error(unquote(code), unquote(default_error))
      else
        json_error(unquote(code), unquote(default_error))
      end
    end
  end

  defmacro build_json_handler() do
    quote do
      def send_202(conn), do: Builder.message(conn, 202, @accepted)

      def send_401(conn) do
        conn
        |> unquote(__CALLER__.module).authenticate()
        |> Builder.message(401, @unauthorized)
      end

      def send_401(conn, error) do
        conn
        |> unquote(__CALLER__.module).authenticate()
        |> Builder.json(401, error)
      end
    end
  end

  defmacro build_siren_handler() do
    quote do
      alias Warlock.Siren

      def send_202(conn) do
        Builder.siren(conn, 202, Siren.message(202, @accepted))
      end

      def send_401(conn) do
        error =
          Siren.error(401, [],
            class: ["error", @unauthorized],
            summary: @unauthorized
          )

        conn
        |> unquote(__CALLER__.module).authenticate()
        |> Builder.siren(401, error)
      end

      def send_401(conn, custom_error) do
        error =
          Siren.error(401, custom_error,
            class: ["error", @unauthorized],
            summary: @unauthorized
          )

        conn
        |> unquote(__CALLER__.module).authenticate()
        |> Builder.siren(401, error)
      end
    end
  end
end
