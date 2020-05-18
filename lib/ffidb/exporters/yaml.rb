# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the YAML markup language.
  class YAML < FFIDB::Exporter
    def begin
      puts "# #{FFIDB.header}" if self.header?
      puts if self.header?
    end

    def export_symbol(symbol, **kwargs)
      @counter ||= 0
      puts unless @counter.zero?
      puts symbol.to_yaml
      @counter += 1
    end
    alias_method :export_typedef, :export_symbol
    alias_method :export_enum, :export_symbol
    alias_method :export_struct, :export_symbol
    alias_method :export_function, :export_symbol
  end # YAML
end # FFIDB::Exporters
