# This is free and unencumbered software released into the public domain.

module FFIDB
  module Symbolic
    ##
    # @return [Symbol]
    def kind
      case
        when self.typedef? then :typedef
        when self.enum? then :enum
        when self.struct? then :struct
        when self.function? then :function
      end
    end

    ##
    # @return [Integer]
    def kind_weight
      case
        when self.typedef? then 0
        when self.enum? then 1
        when self.struct? then 2
        when self.function? then 3
      end
    end

    ##
    # @return [Boolean]
    def typedef?() return false end

    ##
    # @return [Boolean]
    def enum?() return false end

    ##
    # @return [Boolean]
    def struct?() return false end

    ##
    # @return [Boolean]
    def function?() return false end
  end # Symbolic
end # FFIDB
