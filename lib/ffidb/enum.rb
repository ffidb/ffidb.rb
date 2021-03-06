# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'

module FFIDB
  class Enum < ::Struct.new(:name, :values, :comment)
    include Symbolic

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Map<String, Integer>] values
    # @param  [String, #to_s] comment
    def initialize(name, values = {}, comment = nil)
      super(name.to_sym, values || {}, comment&.to_s)
    end

    ##
    # @return [Boolean]
    def enum?() return true end

    ##
    # @return [String]
    def to_s
      "enum #{self.name}"
    end

    ##
    # @return [Hash<Symbol, Type>]
    def to_h
      {
        name: self.name.to_s,
        comment: self.comment,
        values: self.values,
      }.delete_if { |k, v| v.nil? }
    end
  end # Enum
end # FFIDB
