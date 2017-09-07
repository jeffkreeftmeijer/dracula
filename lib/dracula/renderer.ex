defmodule Dracula.Renderer do
  @moduledoc """
  Renders files into HTML output, if needed.
  """

  @doc """
  Renders a file.
  """
  def render(contents, path, layouts \\ [])
  def render(contents, _path, []), do: contents
  def render(contents, path, [layout|tail]) do
    render(
      EEx.eval_string(layout, assigns: [contents: contents]),
      path,
      tail
    )
  end
end
