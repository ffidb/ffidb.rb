# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the CSV file format.
  class CSV < FFIDB::Exporter
    DELIMITER = ','

    def begin
      puts [:library, :kind, :name].join(DELIMITER) # TODO: definition
    end

    def export_symbol(symbol, **kwargs)
      puts [@library&.name, symbol.kind, symbol.name].join(DELIMITER)
    end
    alias_method :export_typedef, :export_symbol
    alias_method :export_enum, :export_symbol
    alias_method :export_struct, :export_symbol
    alias_method :export_union, :export_symbol
    alias_method :export_function, :export_symbol
  end # CSV
end # FFIDB::Exporters
