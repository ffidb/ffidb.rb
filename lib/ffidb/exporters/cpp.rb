# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C++ programming language.
  class Cpp < FFIDB::Exporter
    def begin
      puts "// #{FFIDB.header}"
      puts
      puts "#include <cstdbool>"
      puts "#include <cstddef>"
      puts "#include <cstdint>"
    end

    def begin_library(library)
      @library = library
      puts
      puts "namespace #{library.name} {"
    end

    def finish_library
      puts "} // #{@library.name}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map do |p|
        if p.type.include?('(*)') # function pointer
          p.type.sub('(*)', "(*#{p.name})")
        else
          "#{p.type} #{p.name}"
        end
      end
      puts "  extern \"C\" #{function.type} #{function.name}(#{parameters.join(', ')});"
    end
  end # Cpp
end # FFIDB::Exporters
