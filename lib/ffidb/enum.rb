# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'

module FFIDB
  class Enum < ::Struct.new(:name, :values, :comment)
    include Symbolic
    include Comparable

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Map<String, Integer>] values
    # @param  [String, #to_s] comment
    def initialize(name, values = {}, comment = nil)
      super(name.to_sym, values, comment ? comment.to_s : nil)
    end

    ##
    # @return [Boolean]
    def enum?() return true end

    ##
    # @param  [Parameter] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [String]
    def to_s
      "enum #{self.name}"
    end

    ##
    # @return [Hash<Symbol, Type>]
    def to_h
      {name: self.name.to_s, comment: self.comment}.delete_if { |k, v| v.nil? }
    end

    ##
    # @return [String]
    def to_yaml
      h = self.to_h
      h.transform_keys!(&:to_s)
      h.transform_values! { |v| v.is_a?(Hash) ? v.transform_keys!(&:to_s) : v }
      YAML.dump(h).gsub!("---\n", "--- !enum\n")
    end
  end # Enum
end # FFIDB
