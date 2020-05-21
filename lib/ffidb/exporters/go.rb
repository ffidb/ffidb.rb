# This is free and unencumbered software released into the public domain.

require_relative 'c'

module FFIDB::Exporters
  ##
  # Code generator for the Go programming language (using Cgo).
  #
  # @see https://golang.org/cmd/cgo/
  # @see https://github.com/golang/go/wiki/cgo
  class Go < C
    def finish
      puts self.render_template('go.erb')
    end
  end # Go
end # FFIDB::Exporters
