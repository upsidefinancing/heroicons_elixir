defmodule Heroicons do
  @moduledoc """
  This library provides functions for every [Heroicon](https://github.com/tailwindlabs/heroicons).
  See `Heroicons.Outline` and `Heroicons.Solid` for the two styles of icon.

  Heroicons are designed by [Steve Schoger](https://twitter.com/steveschoger)
  """

  @doc false
  defmacro __before_compile__(%Macro.Env{module: module}) do
    unless Module.has_attribute?(module, :icon_dir) do
      raise CompileError, description: "@icon_dir attrubute is required"
    end

    icon_dir = Module.get_attribute(module, :icon_dir)

    icon_paths =
      Path.absname(icon_dir, :code.priv_dir(:heroicons))
      |> Path.join("*.svg")
      |> Path.wildcard()

    for path <- icon_paths do
      generate_function(path)
    end
  end

  @doc false
  def generate_function(path) do
    name =
      Path.basename(path, ".svg")
      |> String.replace("-", "_")
      |> String.to_atom()

    doc = """
    ![](assets/#{Path.relative_to(path, :code.priv_dir(:heroicons))}) {: width=24px}

    ## Examples
        iex> #{name}()
        iex> #{name}(class: "h-6 w-6 text-gray-500")
    """

    quote do
      @doc unquote(doc)
      @spec unquote(name)(keyword(binary)) :: binary
      def unquote(name)(opts \\ []) do
        icon = File.read!(unquote(path))
        {i, _} = :binary.match(icon, ">")

        {head, tail} = String.split_at(icon, i)

        attrs =
          opts
          |> Enum.map_join(fn {k, v} -> ~s( #{k}="#{v}") end)

        head <> attrs <> tail
      end
    end
  end
end