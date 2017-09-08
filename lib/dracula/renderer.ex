defmodule Dracula.Renderer do
  @moduledoc """
  Renders files into HTML output, if needed.
  """

  @doc """
  Renders a file.
  """
  def render(contents, extname, layouts \\ [])
  def render(contents, ".md", layouts) do
    render(
      Earmark.as_html!(contents, %Earmark.Options{
        footnotes: true,
        heading_anchors: true
      }),
      ".html",
      layouts
    )
  end
  def render(contents, _extname, []), do: contents
  def render(contents, extname, [layout|tail]) do
    render(
      EEx.eval_string(layout, assigns: [contents: contents]),
      extname,
      tail
    )
  end
end
