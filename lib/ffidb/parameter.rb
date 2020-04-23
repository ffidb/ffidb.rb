# This is free and unencumbered software released into the public domain.

module FFIDB
  class Parameter < Struct.new(:name, :type, keyword_init: true)
    include Comparable

    ##
    # @param [FFI::Clang::Cursor] declaration
    def self.parse_declaration(declaration)
      self.new(
        name: declaration.spelling,
        type: declaration.type.spelling,
      )
    end

    ##
    # @return [Boolean]
    def <=>(other)
      self.name <=> other.name
    end
  end # Parameter
end # FFIDB
