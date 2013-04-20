require 'erb'

module Dracula
  module Renderer
    class ERB
      def self.render(content)
        ::ERB.new(content).result(binding)
      end
    end
  end
end
