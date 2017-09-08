defmodule Dracula.Renderer do
  @moduledoc """
  Renders files into HTML output, if needed.
  """

  @doc """
  Renders a file.
  """
  def render(contents, extname, metadata \\ [], layouts \\ [])
  def render(contents, ".eex", metadata, layouts) do
    render(EEx.eval_string(contents, assigns: metadata), ".html", layouts)
  end
  def render(contents, ".md", _metadata, layouts) do
    render(
      Earmark.as_html!(contents, %Earmark.Options{
        footnotes: true,
        heading_anchors: true
      }),
      ".html",
      layouts
    )
  end
  def render(contents, _extname, _metadata, []), do: contents
  def render(contents, extname, _metadata, [layout|tail]) do
    render(
      EEx.eval_string(layout, assigns: [contents: contents]),
      extname,
      tail
    )
  end
end
