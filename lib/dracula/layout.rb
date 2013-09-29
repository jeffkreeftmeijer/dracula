require 'dracula/renderer/erb'

module Dracula
  class Layout
    attr_accessor :path

    def initialize(path, data = {})
      @path = path
      @data = data
    end

    def content
      File.read(path)
    end

    def render(&block)
      Dracula::Renderer::ERB.render(content, @data, &block)
    end
  end
end
