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

    def begin_library(library) end

    def export_symbol(symbol, **kwargs)
      @counter ||= 0
      puts unless @counter.zero?
      puts "# #{symbol.instance_variable_get(:@debug)}" if self.debug? && symbol.instance_variable_get(:@debug)
      puts symbol.to_yaml
      @counter += 1
    end
    alias_method :export_typedef, :export_symbol
    alias_method :export_enum, :export_symbol
    alias_method :export_struct, :export_symbol
    alias_method :export_union, :export_symbol
    alias_method :export_function, :export_symbol

    def finish_library() end
  end # YAML
end # FFIDB::Exporters
