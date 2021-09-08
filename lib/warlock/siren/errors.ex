defmodule Warlock.Siren.Errors do
  @moduledoc """
  Parses errors to their Siren representation.
  """

  alias Warlock.Siren.Errors

  def error_type({_, [validation: :required]}), do: "missing-value"
  def error_type({_, [validation: :cast]}), do: "invalid-value"
  def error_type({_, _}), do: "unknown"

  @doc """
  Formats Ecto.Changeset errors into Siren errors.
  """
  def parse(%{errors: errors}) do
    Enum.reduce(errors, [], fn {key, value}, acc ->
      error = %{
        field: key,
        message: elem(value, 0),
        type: Errors.error_type(value)
      }

      [error | acc]
    end)
  end

  def parse(errors), do: errors
end
