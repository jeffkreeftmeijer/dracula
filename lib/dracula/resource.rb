require 'pathname'
require 'dracula/layout'
require 'dracula/renderer/markdown'
require 'dracula/renderer/erb'

module Dracula
  class Resource
    def initialize(source_path, root_path, data = {}, config = {})
      @source_path = Pathname.new(source_path)
      @root_path = Pathname.new(root_path)
      @data = data
      @config = config
    end

    def output_directory
      return output_root_directory if relative_source_directory.to_s == '.'

      if @config['namespaces'] && namespace = @config['namespaces'][type]
        split_path = relative_source_directory.to_s.split('/')
        split_path[0] = namespace
      end 

      path = File.join(output_root_directory, split_path || relative_source_directory)
      Pathname.new(path)
    end

    def output_path
      Pathname.new(File.join(output_directory, output_basename))
    end

    def raw_content
      File.read(@source_path)
    end

    def content
      content = needs_rendering? ? renderer.render(raw_content) : raw_content

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

    def url
      url = "/#{output_directory.relative_path_from(output_root_directory)}"
      url =~ /\.$/ ? '/' : url
    end

    def type
      type = relative_source_directory.to_s.split('/').first
      return nil if type == '.'
      type
    end

    private 

    def renderer
      case @source_path.extname
      when /markdown$/ 
        Renderer::Markdown
      when /erb$/ 
        Renderer::ERB.new(@data)
      end
    end

    def needs_rendering?
      !renderer.nil?
    end

    def needs_layout?
      output_path.extname == '.html'
    end

    def source_directory
      @source_path.dirname
    end

    def relative_source_directory
      source_directory.relative_path_from(@root_path)
    end

    def output_root_directory
      Pathname.new(File.join(@root_path, '_output'))
    end

    def output_basename
      basename = @source_path.basename.to_s
      basename.gsub!(/\.(.*)/, '.html') if needs_rendering?
      basename
    end
  end
end
