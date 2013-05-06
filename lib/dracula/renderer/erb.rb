require 'erb'

module Dracula
  module Renderer
    class ERB
      def initialize(data = {})
        data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def render(content)
        ::ERB.new(content).result(binding)
      end
    end
  end
end
