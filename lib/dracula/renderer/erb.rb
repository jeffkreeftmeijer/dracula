require 'erb'
module Dracula

  module Renderer
    class ERB
      def self.render(content, data = {})
        data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end

        if content.is_a? Symbol
          content = File.read(File.expand_path("_#{content}.html.erb"))
        end

        ::ERB.new(content).result(binding)
      end
    end
  end
end
