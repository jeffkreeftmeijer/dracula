require 'pathname'
require 'dracula/layout'
require 'dracula/renderer'

module Dracula
  class Resource
    def initialize(source_path, root_path)
      @source_path = Pathname.new(source_path)
      @root_path = Pathname.new(root_path)
    end

    def output_directory
      if relative_source_directory.to_s == '.'
        output_root_directory
      else
        File.join(output_root_directory, relative_source_directory)
      end
    end

    def output_path
      if needs_rendering?
        path = File.join(output_directory, "#{@source_path.basename('.*')}.html")
      else
        path = File.join(output_directory, @source_path.basename)
      end

      Pathname.new(path)
    end

    def raw_content
      File.read(@source_path)
    end

    def content
      content = needs_rendering? ? Renderer.render(raw_content) : raw_content

      layouts.each do |layout|
        content = layout.render { content }
      end

      content 
    end

    def layouts
      paths = [File.join(@root_path, '_layout.html.erb')]
      paths.unshift File.join(@root_path, type, '_layout.html.erb') if type
      
      paths.map { |path| Layout.new(path) if File.exist? path }.compact
    end

    private 

    def needs_rendering?
      @source_path.extname == '.markdown'
    end

    def type
      type = relative_source_directory.to_s
      return nil if type == '.'
      type
    end

    def source_directory
      @source_path.dirname
    end

    def relative_source_directory
      source_directory.relative_path_from(@root_path)
    end

    def output_root_directory
      File.join(@root_path, '_output')
    end
  end
end
