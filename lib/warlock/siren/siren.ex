defmodule Warlock.Siren do
  alias Warlock.Siren
  alias Warlock.Siren.{Errors, Links}

  @ecto_to_siren %{
    :binary_id => "text",
    :boolean => "checkbox",
    :date => "date",
    :datetime => "datetime",
    :integer => "number",
    :string => "text"
  }

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

  def add_required_class(classes, required_fields, field) do
    if Enum.member?(required_fields, field) do
      ["required" | classes]
    else
      classes
    end
  end

  def add_pk_class(classes, primary_keys, field) do
    if Enum.member?(primary_keys, field) do
      ["primary-key" | classes]
    else
      classes
    end
  end

  def field_classes(field, required_fields, primary_keys) do
    []
    |> Siren.add_required_class(required_fields, field)
    |> Siren.add_pk_class(primary_keys, field)
  end

  def fields_spec_from_schema(schema, fields) do
    required_fields = schema.required_fields()
    primary_keys = schema.__schema__(:primary_key)

    fields
    |> Enum.reject(fn field -> Enum.member?(schema.private_fields(), field) end)
    |> Enum.reverse()
    |> Enum.reduce([], fn field, acc ->
      type = Map.get(@ecto_to_siren, schema.__schema__(:type, field), "text")
      classes = Siren.field_classes(field, required_fields, primary_keys)

      [%{name: field, type: type, class: classes} | acc]
    end)
  end

  def writable_fields(schema) do
    Siren.fields_spec_from_schema(schema, schema.writable_fields())
  end

  def readable_fields(schema) do
    Siren.fields_spec_from_schema(schema, schema.__schema__(:fields))
  end
end
