# This is free and unencumbered software released into the public domain.

#require 'erb'
require 'tilt' # https://rubygems.org/gems/tilt
require 'yaml'

module FFIDB
  class Exporter
    def self.for(format) # TODO
      require_relative 'exporters'
      case format&.to_sym
        when :c, :c99, :c11, :c18 then Exporters::C
        when :'c++', :'c++11', :'c++14', :'c++17', :'c++20', :cpp, :cxx then Exporters::Cpp
        when :csv then Exporters::CSV
        when :dart, :flutter then Exporters::Dart
        when :go, :cgo then Exporters::Go
        when :java, :jna then Exporters::Java
        when :json then Exporters::JSON
        when :lisp, :'common-lisp' then Exporters::Lisp
        when :python, :py then Exporters::Python
        when :ruby, :rb then Exporters::Ruby
        # TODO: csharp, haskell, julia, luajit, nim, nodejs, ocaml, php, racket, rust, zig
        when :yaml then Exporters::YAML
        else raise "unknown output format: #{format}"
      end
    end

    attr_reader :options

    def initialize(stream = $stdout, **kwargs)
      @stream = stream
      @options = kwargs.transform_keys(&:to_sym).freeze
    end

    def debug?
      self.options[:debug]
    end

    def verbose?
      self.options[:verbose] || self.debug?
    end

    def header?
      self.options[:header]
    end

    def emit(&block)
      begin
        self.begin
        yield self
        self.finish
      ensure
        self.close
      end
    end

    def dlopen_paths_for(library)
      if library_path = self.options[:library_path]
        library.objects.map { |lib| library_path.delete_suffix('/') << "/" << lib }
      else
        library.objects + library.dlopen
      end
    end

    def begin() end

    def begin_library(library)
      @library = library
      @libraries ||= []
      @libraries << library
      @typedefs ||= {}
      @enums ||= {}
      @structs ||= {}
      @unions ||= {}
      @functions ||= {}
    end

    def export_header(header)
      header.typedefs.sort.each { |typedef| self.export_typedef(typedef) }
      header.enums.sort.each { |enum| self.export_enum(enum) }
      header.structs.sort.each { |struct| self.export_struct(struct) }
      header.unions.sort.each { |union| self.export_union(union) }
      header.functions.sort.each { |function| self.export_function(function) }
    end

    def export_symbol(symbol, disabled: nil)
      self.__send__("export_#{symbol.kind}", symbol, disabled: disabled)
    end

    def export_typedef(typedef, disabled: nil)
      (@typedefs[@library] ||= []) << typedef
    end

    def export_enum(enum, disabled: nil)
      (@enums[@library] ||= []) << enum
    end

    def export_struct(struct, disabled: nil)
      (@structs[@library] ||= []) << struct
    end

    def export_union(union, disabled: nil)
      (@unions[@library] ||= []) << union
    end

    def export_function(function, disabled: nil)
      (@functions[@library] ||= []) << function
    end

    def finish_library
      @library = nil
    end

    def finish() end

    def close() end

    protected

    def format_comment(comment, prefix)
      prefix = prefix + ' '
      comment.each_line.map(&:strip).map { |s| s.prepend(prefix) }.join("\n")
    end

    def puts(*args)
      @stream.puts *args
    end

    def print(*args)
      @stream.print *args
    end

    def render_template(template_name)
      #ERB.new(self.load_template(template_name)).result(binding)
      Tilt.new(self.path_to_template(template_name)).render(self)
    end

    def load_template(template_name)
      File.read(self.path_to_template(template_name))
    end

    def path_to_template(template_name)
      File.expand_path("../../etc/templates/#{template_name}", __dir__)
    end
  end # Exporter
end # FFIDB
