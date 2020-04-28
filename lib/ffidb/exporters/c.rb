# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C programming language.
  class C < FFIDB::Exporter
    def begin
      puts "// #{FFIDB.header}"
      puts
      puts "#include <stdbool.h>"
      puts "#include <stddef.h>"
      puts "#include <stdint.h>"
    end

    def begin_library(library)
      puts
      puts "// #{library.name}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map do |p|
        if p.type.include?('(*)') # function pointer
          p.type.sub('(*)', "(*#{p.name})")
        else
          "#{p.type} #{p.name}"
        end
      end
      puts "extern #{function.type} #{function.name}(#{parameters.join(', ')});"
    end
  end # C
end # FFIDB::Exporters
