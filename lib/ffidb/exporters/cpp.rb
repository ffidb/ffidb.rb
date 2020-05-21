# This is free and unencumbered software released into the public domain.

require_relative 'c'

module FFIDB::Exporters
  ##
  # Code generator for the C++ programming language.
  class Cpp < C
    def finish
      puts self.render_template('cpp.erb')
    end
  end # Cpp
end # FFIDB::Exporters
