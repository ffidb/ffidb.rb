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
      @json[@library&.name] ||= {}
    end

    def export_symbol(symbol, **kwargs)
      @json[@library&.name][symbol.name] = {kind: symbol.kind.to_s}.merge!(symbol.to_h)
    end
    alias_method :export_typedef, :export_symbol
    alias_method :export_enum, :export_symbol
    alias_method :export_struct, :export_symbol
    alias_method :export_union, :export_symbol
    alias_method :export_function, :export_symbol

    def finish_library
      @library = nil
    end

    def finish
      puts ::JSON.pretty_generate(@json)
    end
  end # JSON
end # FFIDB::Exporters
