defmodule Warlock.Siren.Links do
  alias Warlock.Siren.Links
  alias Warlock.Utils
  alias Plug.Conn

  def parse_uri(conn), do: conn |> Conn.request_url() |> URI.parse()

  def decode_query(%{query: nil}), do: %{}
  def decode_query(url), do: url |> Map.get(:query) |> URI.decode_query()

  def make(rel, href), do: %{rel: [rel], href: href}

  @doc """
  Creates an updated uri to a new page.
  """
  def change_page(conn, new_page) do
    url = Links.parse_uri(conn)

    query =
      url
      |> Links.decode_query()
      |> Map.put("page", new_page)
      |> URI.encode_query()

    url
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  @doc """
  Adds a link to the next page, if it's not the last page.
  """
  def add_next(links, conn, count) do
    page = Utils.get_page(conn)
    items = Utils.get_items(conn)

    if page * items < count do
      [Links.make("next", Links.change_page(conn, page + 1)) | links]
    else
      links
    end
  end

  @doc """
  Adds a link to the last page
  """
  def add_last(links, conn, count) do
    last_page = ceil(count / Utils.get_items(conn))
    [Links.make("last", Links.change_page(conn, last_page)) | links]
  end

  @doc """
  Adds a link to the previous page, if it's not the first page.
  """
  def add_prev(links, %{query_params: %{"page" => current_page}} = conn) do
    page = String.to_integer(current_page)

    if page == 1 do
      links
    else
      [Links.make("prev", Links.change_page(conn, page - 1)) | links]
    end
  end

  def add_prev(links, _conn), do: links

  def add_self(links, conn) do
    [Links.make("self", Conn.request_url(conn)) | links]
  end

  def add_first(links, conn) do
    [Links.make("first", Links.change_page(conn, 1)) | links]
  end
end
