# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'
require_relative 'type'

module FFIDB
  class Typedef < ::Struct.new(:name, :type, :comment)
    include Symbolic

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Type] type
    # @param  [String, #to_s] comment
    def initialize(name, type, comment = nil)
      super(name.to_sym, Type.for(type), comment&.to_s)
    end

    ##
    # @return [Boolean]
    def typedef?() return true end

    ##
    # @return [String]
    def to_s
      "typedef #{self.type} #{self.name}"
    end

    ##
    # @return [Hash<Symbol, Type>]
    def to_h
      {
        name: self.name.to_s,
        type: self.type.to_s,
        comment: self.comment,
      }.delete_if { |k, v| v.nil? }
    end
  end # Typedef
end # FFIDB
