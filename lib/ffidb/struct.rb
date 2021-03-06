# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'

module FFIDB
  class Struct < ::Struct.new(:name, :fields, :comment)
    include Symbolic

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Map<Symbol, Type>] fields
    # @param  [String, #to_s] comment
    def initialize(name, fields = {}, comment = nil)
      super(name.to_sym, fields || {}, comment&.to_s)
    end

    ##
    # @return [Boolean]
    def struct?() return true end

    ##
    # @return [Boolean]
    def opaque?() !self.fields || self.fields.empty? end

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
        fields: self.opaque? ? nil : self.fields&.transform_values { |t| t.to_s },
      }.delete_if { |k, v| v.nil? }
    end
  end # Struct
end # FFIDB
