defmodule Warlock.Model do
  alias Warlock.{Model, ModuleUtils, Schema}

  @callback new(params :: map(), user :: Schema.user()) :: Schema.query_result()
  @callback get(params :: map(), user :: Schema.user()) :: Schema.query_result()
  @callback get_count(params :: map(), user :: Schema.user()) ::
              Schema.query_result()
  @callback show(id :: any(), user :: Schema.user()) :: Schema.query_result()
  @callback update(item :: Schema.t(), params :: map()) :: Schema.query_result()
  @callback edit(params :: map(), id :: any(), user :: Schema.user()) ::
              Schema.query_result()
  @callback delete(id :: any(), user :: Schema.user()) :: Schema.query_result()

  @optional_callbacks new: 2,
                      get: 2,
                      get_count: 2,
                      show: 2,
                      update: 2,
                      edit: 3,
                      delete: 2

  defmacro __using__(opts \\ []) do
    quote do
      schema = unquote(ModuleUtils.replace_at(__CALLER__.module, "Schemas"))

      alias unquote(ModuleUtils.replace_at(__CALLER__.module, "Schemas"))

      @behaviour Model

      @schema Keyword.get(unquote(opts), :schema, schema)
      @admin Keyword.get(unquote(opts), :admin, nil)

      def is_admin?(nil), do: false
      def is_admin?(user), do: if(user == @admin, do: true, else: false)

      @impl true
      def new(params, user), do: @schema.new(params, user)

      @impl true
      def get(params, user), do: @schema.get(params, user)

      @impl true
      def get_count(params, user), do: @schema.get_count(params, user)

      @impl true
      def show(id, user), do: @schema.show(id, user)

      @impl true
      def update(item, params), do: @schema.update(item, params)

      @impl true
      def edit(params, id, user), do: @schema.edit(params, id, user)

      @impl true
      def delete(id, user), do: @schema.delete(id, user)

      defoverridable is_admin?: 1,
                     new: 2,
                     get: 2,
                     get_count: 2,
                     show: 2,
                     update: 2,
                     edit: 3,
                     delete: 2
    end
  end
end
