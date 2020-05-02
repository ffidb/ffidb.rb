# This is free and unencumbered software released into the public domain.

require_relative 'c'

module FFIDB::Exporters
  ##
  # Code generator for the Go programming language (using Cgo).
  #
  # @see https://golang.org/cmd/cgo/
  # @see https://github.com/golang/go/wiki/cgo
  class Go < C
    def begin
      puts "// #{FFIDB.header}"
      puts
      puts "/*"
      puts "#include <stdarg.h>    // for va_list"
      puts "#include <stdbool.h>   // for _Bool"
      puts "#include <stddef.h>    // for size_t, wchar_t"
      puts "#include <stdint.h>    // for {,u}int*_t"
      puts "#include <sys/types.h> // for off_t, ssize_t"
    end

    def finish
      puts "*/"
      puts 'import "C"'
    end

    def begin_library(library)
      puts
      puts "// #{library.name} API"
      puts "#cgo LDFLAGS: -l#{library.dlopen}"
    end
  end # Go
end # FFIDB::Exporters
