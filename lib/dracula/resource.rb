require 'pathname'
require 'dracula/layout'
require 'dracula/renderer/markdown'

module Dracula
  class Resource
    def initialize(source_path, root_path, config = {})
      @source_path = Pathname.new(source_path)
      @root_path = Pathname.new(root_path)
      @config = config
    end

    def output_directory
      return output_root_directory if relative_source_directory.to_s == '.'

      if @config['namespaces'] && namespace = @config['namespaces'][type]
        split_path = relative_source_directory.to_s.split('/')
        split_path[0] = namespace
      end 

      File.join(output_root_directory, split_path || relative_source_directory)
    end

    def output_path
      Pathname.new(File.join(output_directory, output_basename))
    end

    def raw_content
      File.read(@source_path)
    end

    def content
      content = needs_rendering? ? Renderer::Markdown.render(raw_content) : raw_content

      layouts.each do |layout|
        content = layout.render { content }
      end

      content 
    end

    def layouts
      paths = []

      if needs_layout?
        paths << File.join(@root_path, type, '_layout.html.erb') if type
        paths << File.join(@root_path, '_layout.html.erb')
      end

      paths.map { |path| Layout.new(path) if File.exist? path }.compact
    end

    private 

    def needs_rendering?
      %w(.markdown .erb).include? @source_path.extname 
    end

    def needs_layout?
      output_path.extname == '.html'
    end

    def type
      type = relative_source_directory.to_s.split('/').first
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

    def output_basename
      basename = @source_path.basename.to_s
      basename.gsub!(/\.(.*)/, '.html') if needs_rendering?
      basename
    end
  end
end
