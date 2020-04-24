# This is free and unencumbered software released into the public domain.

require_relative 'location'

require 'pathname'

module FFIDB
  class Function < Struct.new(:name, :type, :parameters, :comment, :definition, keyword_init: true)
    include Comparable

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @param  [Pathname, #to_s] base_directory
    # @return [Function]
    def self.parse_declaration(declaration, base_directory: nil)
      self.new(
        name: declaration.spelling,
        type: declaration.type.canonical.spelling,
        parameters: [],
        comment: declaration.comment&.text,
        definition: Location.parse_clang_location(declaration.location, base_directory: base_directory),
      )
    end

    ##
    # @param  [Function] other
    # @return [Integer]
    def <=>(other) self.name <=> other.name end

    ##
    # @return [Boolean]
    def public?() self.name[0] != '_' end

    ##
    # @return [Boolean]
    def nonpublic?() !(self.public?) end

    ##
    # @return [Boolean]
    def nullary?() self.arity.zero? end

    ##
    # @return [Boolean]
    def unary?() self.arity.equal?(1) end

    ##
    # @return [Boolean]
    def binary?() self.arity.equal?(2) end

    ##
    # @return [Boolean]
    def ternary?() self.arity.equal?(3) end

    ##
    # @return [Integer]
    def arity() self.parameters.size end

    ##
    # @return [String]
    def result_type
      self.type.split('(', 2).first.strip
    end
    alias_method :return_type, :result_type
  end # Function
end # FFIDB
