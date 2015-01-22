require File.expand_path('../../test_helper', __FILE__)
require 'dracula/renderer/markdown'

describe Dracula::Renderer::Markdown do
  it "renders Markdown" do
    Dracula::Renderer::Markdown.render('foo *bar* **baz**').should == "<p>foo <em>bar</em> <strong>baz</strong></p>\n"
  end

  it "highlights embedded code blocks" do
    Dracula::Renderer::Markdown.render("```ruby\nbar\n```").should == "<div class=\"highlight\"><pre><span class=\"n\">bar</span>\n</pre></div>\n"
  end

  it "unescapes html entities in code blocks" do
    output = Dracula::Renderer::Markdown.render("```ruby\nputs['foo', \"bar\"]\n```")
    output.should.include '&#39;foo&#39;'
    output.should.include '&quot;bar&quot;'
  end

  it "automatically converts URLs into links" do
    Dracula::Renderer::Markdown.render("www.example.com").should == "<p><a href=\"http://www.example.com\">www.example.com</a></p>\n"
  end

  it "handles footnotes" do
    Dracula::Renderer::Markdown.render("This is a sentence.[^1]\n [^1]: This is a footnote.").should == "<p>This is a sentence.<sup id=\"fnref1\"><a href=\"#fn1\" rel=\"footnote\">1</a></sup></p>\n\n<div class=\"footnotes\">\n<hr>\n<ol>\n\n<li id=\"fn1\">\n<p>This is a footnote.&nbsp;<a href=\"#fnref1\" rev=\"footnote\">&#8617;</a></p>\n</li>\n\n</ol>\n</div>\n"
  end
end
