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

  test "renders a markdown page, with footnotes" do
    assert Renderer.render("foot ... [^1]\n\n[^1]: ... note!", ".md") ==
      ~s{<p>foot … <a href=\"#fn:1\" id=\"fnref:1\" class=\"footnote\" title=\"see footnote\">1</a></p>\n<div class=\"footnotes\">\n<hr>\n<ol>\n<li id=\"fn:1\"><p>… note!&nbsp;<a href=\"#fnref:1\" title=\"return to article\" class=\"reversefootnote\">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>}
  end

  test "renders an HTML page with a layout" do
    assert Renderer.render(
      "<!-- index.html -->\n",
      ".html",
      ["<!-- _layout.eex -->\n<%= @contents %>"]
    ) == "<!-- _layout.eex -->\n<!-- index.html -->\n"
  end
end

