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

    def export_function(function)
      @counter ||= 0
      puts unless @counter.zero?
      puts function.to_yaml
      @counter += 1
    end
  end # YAML
end # FFIDB::Exporters
