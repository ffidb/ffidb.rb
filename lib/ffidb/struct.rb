# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'

module FFIDB
  class Struct < ::Struct.new(:name, :fields, :comment)
    include Symbolic
    include Comparable

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Map<Symbol, Type>] fields
    # @param  [String, #to_s] comment
    def initialize(name, fields = {}, comment = nil)
      super(name.to_sym, fields, comment ? comment.to_s : nil)
    end

    ##
    # @return [Boolean]
    def struct?() return true end

    ##
    # @param  [Parameter] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [String]
    def to_s
      "struct #{self.name}"
    end

    ##
    # @return [Hash<Symbol, Type>]
    def to_h
      {
        name: self.name.to_s,
        comment: self.comment,
        fields: self.fields,
      }.delete_if { |k, v| v.nil? }
    end

    ##
    # @return [String]
    def to_yaml
      h = self.to_h
      h.transform_keys!(&:to_s)
      h.transform_values! { |v| v.is_a?(Hash) ? v.transform_keys!(&:to_s) : v }
      YAML.dump(h).gsub!("---\n", "--- !struct\n")
    end
  end # Struct
end # FFIDB
