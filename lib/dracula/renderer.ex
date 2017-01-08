defmodule Dracula.Renderer do
  @doc ~S"""
  Renders Markdown and Liquid resources, and adds layouts.

  ## Examples
  
  Given a Markdown resource, `render/1` returns rendered HTML contents.

    iex> Dracula.Renderer.render(%{input_path: "index.md", contents: "index.md"})
    "<p>index.md</p>\n"
  """
  def render(%{contents: contents}), do: "<p>" <> contents <> "</p>\n"
end
