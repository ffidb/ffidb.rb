# This is free and unencumbered software released into the public domain.

module FFIDB
  class Parameter < Struct.new(:name, :type, keyword_init: true)
    include Comparable

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @param. [String, #to_s] default_name
    # @return [Parameter]
    def self.parse_declaration(declaration, default_name: '_')
      name = declaration.spelling
      self.new(
        name: (name.nil? || name.empty?) ? default_name.to_s : name,
        type: declaration.type.spelling,
      )
    end

    ##
    # @param  [Parameter] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [Hash<String, String>]
    def to_h
      {self.name => self.type}
    end
  end # Parameter
end # FFIDB
