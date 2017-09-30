defmodule Dracula.Renderer do
  @moduledoc """
  Renders files into HTML output, if needed.
  """

  @doc """
  Renders a file.
  """
  def render(contents, extname, metadata \\ [], layouts \\ [])
  def render(contents, ".eex", metadata, layouts) do
    render(EEx.eval_string(contents, assigns: metadata), ".html", metadata, layouts)
  end
  def render(contents, ".md", metadata, layouts) do
    render(
      Earmark.as_html!(contents, %Earmark.Options{
        footnotes: true,
        heading_anchors: true,
        code_class_prefix: "language-"
      }),
      ".html",
      metadata,
      layouts
    )
  end
  def render(contents, _extname, _metadata, []), do: contents
  def render(contents, extname, metadata, [layout|tail]) do
    assigns = Keyword.merge([contents: contents], metadata)
    render(
      EEx.eval_string(layout, assigns: assigns),
      extname,
      metadata,
      tail
    )
  end
end
