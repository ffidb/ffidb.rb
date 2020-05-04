# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

require 'json'

module FFIDB::Exporters
  ##
  # Code generator for the JSON data interchange language.
  class JSON < FFIDB::Exporter
    def begin
      # No header, because JSON doesn't support comments
      @json = {}
    end

    def begin_library(library)
      @library = library
      @json[@library.name] ||= {}
    end

    def export_function(function)
      @json[@library.name][function.name] = function.to_h
    end

    def finish_library
      @library = nil
    end

    def finish
      puts ::JSON.pretty_generate(@json)
    end
  end # JSON
end # FFIDB::Exporters
