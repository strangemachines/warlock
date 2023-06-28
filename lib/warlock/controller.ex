if Code.ensure_loaded?(Ecto) do
  defmodule Warlock.Controller do
    alias Warlock.{Controller, ModuleUtils, Schema}

    @callback new(params :: map(), user :: Schema.user()) ::
                Schema.query_result()
    @callback get(params :: map(), user :: Schema.user()) ::
                Schema.query_result()
    @callback get_count(params :: map(), user :: Schema.user()) ::
                Schema.query_result()
    @callback show(id :: any(), user :: Schema.user()) :: Schema.query_result()
    @callback edit(params :: map(), id :: any(), user :: Schema.user()) ::
                Schema.query_result()
    @callback delete(id :: any(), user :: Schema.user()) ::
                Schema.query_result()

    @optional_callbacks new: 2,
                        get: 2,
                        get_count: 2,
                        show: 2,
                        edit: 3,
                        delete: 2

    @doc """
    Takes the result of query and normalizes it to a tuple.
    """
    def list_to_outcome(list) do
      case list do
        [] -> {:error, :not_found}
        [item] -> {:ok, item}
        _ -> {:error, :too_many_items}
      end
    end

    defmacro __using__(opts \\ []) do
      quote do
        model = unquote(ModuleUtils.replace_at(__CALLER__.module, "Models"))

        alias unquote(ModuleUtils.replace_at(__CALLER__.module, "Models"))

        alias Warlock.Controller, as: WarlockController

        @behaviour Controller

        @model Keyword.get(unquote(opts), :model, model)

        @impl true
        def new(params, user), do: @model.new(params, user)

        @impl true
        def get(params, user), do: @model.get(params, user)

        @impl true
        def get_count(params, user), do: @model.get_count(params, user)

        @impl true
        def show(id, user), do: @model.show(id, user)

        @impl true
        def edit(params, id, user), do: @model.edit(params, id, user)

        @impl true
        def delete(id, user), do: @model.delete(id, user)

        defoverridable new: 2,
                       get: 2,
                       get_count: 2,
                       show: 2,
                       edit: 3,
                       delete: 2
      end
    end
  end
else
  defmodule Warlock.Controller do
  end
end
