require 'pathname'
require 'yaml'
require 'dracula/layout'
require 'dracula/renderer/markdown'
require 'dracula/renderer/erb'

module Dracula
  class Resource
    attr_writer :data

    def initialize(source_path, root_path)
      @source_path = Pathname.new(source_path)
      @root_path = Pathname.new(root_path)
    end

    def output_directory
      return output_root_directory if relative_source_directory.to_s == '.'

      if type
        split_path = relative_source_directory.to_s.split('/')
        split_path.shift
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

    def content(options = {layout: true})
      content = needs_rendering? ? renderer.render(raw_content, data) : raw_content
      options.merge!(Hash[metadata.map {|k,v| [k.to_sym, v]}])

      if options[:layout]
        layouts.each do |layout|
          content = layout.render { content }
        end
      end

      content 
    end

    def layouts
      paths = []

      if needs_layout?
        paths << File.join(@root_path, "_#{type}", '_layout.html.erb') if type
        paths << File.join(@root_path, '_layout.html.erb')
      end

      paths.map { |path| Layout.new(path, data) if File.exist? path }.compact
    end

    def url
      url = "/#{output_directory.relative_path_from(output_root_directory)}"
      url =~ /\.$/ ? '/' : url
    end

    def type
      directory_name = relative_source_directory.to_s.split('/').first
      $1 if directory_name =~ /_(.*)/
    end

    def metadata
      metadata_path
      return {} unless File.exist?(metadata_path)
      YAML.load_file(metadata_path)
    end

    private 

    def data
      @data ||= {}
    end

    def renderer
      case @source_path.extname
      when /markdown$/ 
        Renderer::Markdown
      when /erb$/ 
        Renderer::ERB
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

    def source_extname
      @source_path.to_s[/\..+/]
    end

    def metadata_path
      File.join(source_directory, '_metadata.yml')
    end

    def output_root_directory
      Pathname.new(File.join(@root_path, '_output'))
    end

    def output_basename
      basename = @source_path.basename.to_s

      case source_extname
      when /markdown$/
        basename.gsub!(/\..+/, '.html')
      when /erb$/
        basename.gsub!(/\.[^.]+$/, '')
      end

      basename
    end
  end
end
