require 'dracula/renderer/erb'

module Dracula
  class Layout
    attr_accessor :path

    def initialize(path, data = {})
      @path = path
      @renderer = Dracula::Renderer::ERB.new(data)
    end

    def content
      File.read(path)
    end

    def render(&block)
      @renderer.render(content, &block)
    end
  end
end
