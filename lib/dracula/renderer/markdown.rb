require 'redcarpet'
require 'pygments'
require 'cgi'

module Dracula
  module Renderer
    class Markdown
      def self.markdown
        Redcarpet::Markdown.new(
          Redcarpet::Render::HTML, 
          :fenced_code_blocks => true,
          :autolink => true
        )
      end

      def self.render(content, data = {})
        inline_highlight(markdown.render(content))
      end

      def self.inline_highlight(html)
        html.gsub %r(<pre><code class=\"([^"]*)\">([^<]*)</code></pre>) do
          Pygments.highlight(CGI.unescapeHTML($2), :lexer => $1)
        end
      end
    end
  end
end
