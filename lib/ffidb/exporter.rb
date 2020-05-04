# This is free and unencumbered software released into the public domain.

module FFIDB
  class Exporter
    def self.for(format) # TODO
      require_relative 'exporters'
      case format&.to_sym
        when :c, :c99, :c11, :c18 then Exporters::C
        when :'c++', :'c++11', :'c++14', :'c++17', :'c++20', :cpp, :cxx then Exporters::Cpp
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

    def begin_library(library) end

    def export_function(function)
      raise "not implemented" # subclasses must implement this
    end

    def finish_library() end

    def finish() end

    def close() end

    private

    def puts(*args)
      @stream.puts *args
    end

    def print(*args)
      @stream.print *args
    end
  end # Exporter
end # FFIDB
