# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C programming language.
  class C < FFIDB::Exporter
    def begin
      puts "// #{FFIDB.header}"
    end

    def begin_library(library)
      puts
      puts "// #{library.name}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| "#{p.type} #{p.name}" }
      puts "extern #{function.type} #{function.name}(#{parameters.join(', ')});"
    end
  end # C
end # FFIDB::Exporters
