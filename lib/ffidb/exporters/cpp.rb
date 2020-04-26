# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C++ programming language.
  class Cpp < FFIDB::Exporter
    def begin
      puts "// #{FFIDB.header}"
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
      parameters = function.parameters.each_value.map { |p| "#{p.type} #{p.name}" }
      puts "  extern \"C\" #{function.type} #{function.name}(#{parameters.join(', ')});"
    end
  end # Cpp
end # FFIDB::Exporters
