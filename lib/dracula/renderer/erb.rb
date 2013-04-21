require 'erb'

module Dracula
  module Renderer
    class ERB
      def initialize(binding = binding)
        @binding = binding
      end

      def render(content)
        ::ERB.new(content).result(@binding)
      end
    end
  end
end
