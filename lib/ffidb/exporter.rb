# This is free and unencumbered software released into the public domain.

module FFIDB
  class Exporter
    def self.for(format) # TODO
      require_relative 'exporters'
      case format&.to_sym
        when :c then Exporters::C
        when :cpp, :cxx, :'c++' then Exporters::Cpp
        when :python, :py then Exporters::Python
        when :ruby, :rb then Exporters::Ruby
        # TODO: dart, go, java, lisp, ocaml, php, racket, ruby, zig
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

    def emit(&block)
      begin
        self.begin
        yield self
        self.finish
      ensure
        self.close
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
