# This is free and unencumbered software released into the public domain.

require_relative 'location'

require 'pathname'
require 'yaml'

module FFIDB
  class Function < Struct.new(:name, :type, :parameters, :definition, :comment, keyword_init: true)
    include Comparable

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

    ##
    # @return [Hash<Symbol, Object>]
    def to_h
      {
        name: self.name,
        type: self.type,
        parameters: self.parameters&.transform_values { |v| v.type },
        definition: self.definition&.to_h,
        comment: self.comment,
      }
    end

    ##
    # @return [String]
    def to_yaml
      YAML.dump(self.to_h.transform_keys!(&:to_s).transform_values do |v|
        v.is_a?(Hash) ? v.transform_keys!(&:to_s) : v
      end).gsub!("---\n", "--- !function\n")
    end
  end # Function
end # FFIDB
