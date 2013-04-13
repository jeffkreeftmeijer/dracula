require 'erb'
module Dracula

  class Layout
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def content
      File.read(path)
    end

    def render
      ERB.new(content).result(binding)
    end
  end
end
