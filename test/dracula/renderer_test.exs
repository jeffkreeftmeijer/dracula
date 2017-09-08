defmodule Dracula.RendererTest do
  use ExUnit.Case
  alias Dracula.Renderer

  test "renders a plain HTML page" do
    assert Renderer.render("<!-- index.html -->\n", "index.html") ==
      "<!-- index.html -->\n"
  end

  test "renders a markdown page, with heading anchors" do
    assert Renderer.render("# index.md", ".md") ==
      ~s{<a id="indexmd"></a><h1>index.md</h1>\n}
  end

  test "renders an HTML page with a layout" do
    assert Renderer.render(
      "<!-- index.html -->\n",
      ".html",
      ["<!-- _layout.eex -->\n<%= @contents %>"]
    ) == "<!-- _layout.eex -->\n<!-- index.html -->\n"
  end
end

