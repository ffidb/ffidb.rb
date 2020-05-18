# This is free and unencumbered software released into the public domain.

module FFIDB
  class Parameter < ::Struct.new(:name, :type)
    include Comparable

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Type] type
    def initialize(name, type = nil)
      raise ArgumentError, "Expected FFIDB::Type, got #{type.inspect}" if type && !type.is_a?(Type)
      super(name.to_sym, type)
    end

    ##
    # @param  [Parameter] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [String]
    def to_s
      "#{self.name}: #{self.type}"
    end

    ##
    # @return [Hash<Symbol, Type>]
    def to_h
      {self.name => self.type}
    end
  end # Parameter
end # FFIDB
