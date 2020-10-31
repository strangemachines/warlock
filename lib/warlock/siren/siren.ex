defmodule Warlock.Siren do
  alias Warlock.Siren
  alias Warlock.Siren.{Errors, Links}

  @summary "The request could not be processed because of an unspecified error"

  def links(conn, count) do
    []
    |> Links.add_self(conn)
    |> Links.add_prev(conn)
    |> Links.add_first(conn)
    |> Links.add_next(conn, count)
    |> Links.add_last(conn, count)
  end

  @doc """
  Encodes a payload to Siren.
  """
  def encode(conn, payload, count) do
    %{
      entities: payload,
      links: Siren.links(conn, count)
    }
  end

  def encode(conn, payload) do
    %{properties: payload, links: Links.add_self([], conn)}
  end

  def error(404) do
    %{
      class: ["error", "not-found"],
      properties: %{code: 404, summary: "This resource does not exist."}
    }
  end

  def error(code, errors, opts \\ []) do
    class = Keyword.get(opts, :class, "error")
    summary = Keyword.get(opts, :summary, @summary)

    %{
      class: [class],
      properties: %{code: code, summary: summary, errors: Errors.parse(errors)}
    }
  end
end
