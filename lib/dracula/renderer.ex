defmodule Dracula.Renderer do
  @doc ~S"""
  Renders Markdown and Liquid resources, and adds layouts.

  ## Examples
  
  Given a Markdown or Liquid resource, `render/1` returns rendered HTML
  contents.

    iex> Dracula.Renderer.render(%{"input_path" => "index.md", "contents" => "index.md"})
    "<p>index.md</p>\n"

    iex> Dracula.Renderer.render(%{"input_path" => "index.liquid", "contents" => "{{ \"index.liquid\" }}"})
    "index.liquid"
  """
  def render(%{"contents" => contents, "input_path" => path}) do
    case Path.extname(path) do
      ".liquid" ->
        {:ok, rendered, _} = contents
        |> Liquid.Template.parse
        |> Liquid.Template.render
        rendered
      ".md" -> Earmark.to_html(contents)
      _ -> contents
    end
  end
end
