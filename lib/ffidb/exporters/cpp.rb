# This is free and unencumbered software released into the public domain.

require_relative 'c'

module FFIDB::Exporters
  ##
  # Code generator for the C++ programming language.
  class Cpp < C
    SYMBOL_INDENT    = 2
    EXTERN_QUALIFIER = 'extern "C"'

    def begin
      puts "// #{FFIDB.header}"
      puts
      puts "#include <cstdarg>     // for va_list"
      puts "#include <cstdbool>    // for bool" # not needed in C++
      puts "#include <cstddef>     // for size_t"
      puts "#include <cstdint>     // for {,u}int*_t"
      puts "#include <sys/types.h> // for off_t"
    end

    def begin_library(library)
      @library = library
      @namespace = self.options[:module] || library.name
      puts
      puts "namespace #{@namespace} {"
    end

    def finish_library
      puts "} // #{@namespace}"
    end
  end # Cpp
end # FFIDB::Exporters
