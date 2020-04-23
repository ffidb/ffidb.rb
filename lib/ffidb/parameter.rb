# This is free and unencumbered software released into the public domain.

module FFIDB
  class Parameter < Struct.new(:name, :type, keyword_init: true)
    ##
    # @param [FFI::Clang::Cursor] declaration
    def self.parse_declaration(declaration)
      self.new() # TODO
    end
  end # Parameter
end # FFIDB
