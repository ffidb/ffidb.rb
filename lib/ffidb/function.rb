# This is free and unencumbered software released into the public domain.

require_relative 'location'
require_relative 'symbolic'

require 'pathname'
require 'yaml'

module FFIDB
  class Function < ::Struct.new(:name, :type, :parameters, :definition, :comment, keyword_init: true)
    include Symbolic

    alias_method :result_type, :type
    alias_method :return_type, :type

    ##
    # @return [Boolean]
    def function?() return true end

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
    # @return [Hash<Symbol, Object>]
    def to_h
      {
        name: self.name.to_s,
        type: self.type.to_s,
        parameters: self.parameters&.transform_values { |v| v.type.to_s },
        definition: self.definition&.to_h,
        comment: self.comment,
      }.delete_if { |k, v| v.nil? }
    end

    ##
    # @return [String]
    def to_yaml
      h = self.to_h
      h.delete(:parameters) if h[:parameters].empty?
      h.transform_keys!(&:to_s)
      h.transform_values! { |v| v.is_a?(Hash) ? v.transform_keys!(&:to_s) : v }
      YAML.dump(h).gsub!("---\n", "--- !#{self.kind}\n")
    end
  end # Function
end # FFIDB
