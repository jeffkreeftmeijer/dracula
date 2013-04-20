require File.expand_path('../../test_helper', __FILE__)
require 'dracula/renderer/markdown'

describe Dracula::Renderer::Markdown do
  it "renders Markdown" do
    Dracula::Renderer::Markdown.render('foo *bar* **baz**').should == "<p>foo <em>bar</em> <strong>baz</strong></p>\n"
  end

  it "highlights embedded code blocks" do
    Dracula::Renderer::Markdown.render("```ruby\nbar\n```").should == "<div class=\"highlight\"><pre><span class=\"n\">bar</span>\n</pre></div>\n"
  end
end
