# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the YAML markup language.
  class YAML < FFIDB::Exporter
    def export_function(function)
      puts
      puts function.to_yaml
    end
  end # YAML
end # FFIDB::Exporters
