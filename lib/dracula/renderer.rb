require 'redcarpet'
require 'pygments'

module Dracula
  class Renderer
    def self.markdown
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
    end

    def self.render(content)
      inline_highlight(markdown.render(content))
    end

    def self.inline_highlight(html)
      html.gsub %r(<pre><code class=\"([^"]*)\">([^<]*)</code></pre>) do
        Pygments.highlight($2, :lexer => $1)
      end
    end
  end
end
