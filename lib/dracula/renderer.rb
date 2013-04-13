require 'redcarpet'
require 'pygments'
require 'nokogiri'

module Dracula
  class Renderer
    def self.markdown
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
    end

    def self.render(content)
      inline_highlight(markdown.render(content))
    end

    def self.inline_highlight(html)
      doc = Nokogiri::HTML(html)
      doc.search("//code[@class]").each do |code|
        code.replace Pygments.highlight(code.text.rstrip, :lexer => code[:class])
      end
      doc.at_css("body").inner_html.to_s + "\n"
    end
  end
end
