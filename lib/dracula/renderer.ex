defmodule Dracula.Renderer do
  @moduledoc """
  Renders files into HTML output, if needed.
  """

  @doc """
  Renders a file.
  """
  def render(contents, path, layouts \\ [])
  def render(contents, ".md", layouts) do
    render(
      Earmark.as_html!(contents),
      ".html",
      layouts
    )
  end
  def render(contents, _path, []), do: contents
  def render(contents, path, [layout|tail]) do
    render(
      EEx.eval_string(layout, assigns: [contents: contents]),
      path,
      tail
    )
  end
end
