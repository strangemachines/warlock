defmodule Warlock.Siren do
  alias Warlock.Siren
  alias Warlock.Siren.{Errors, Links}

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
      properties: %{items: count},
      entities: payload,
      links: Siren.links(conn, count)
    }
  end

  def encode(conn, payload) do
    %{properties: payload, links: Links.add_self([], conn)}
  end

  @doc """
  Produces an informational response.
  """
  def message(code, message) do
    %{properties: %{code: code, summary: message}}
  end

  def error(code, errors, opts \\ []) do
    class = Keyword.get(opts, :class, ["error", "unknown"])
    summary = Keyword.get(opts, :summary, "unknown error")

    %{
      class: class,
      properties: %{code: code, summary: summary, errors: Errors.parse(errors)}
    }
  end
end
