# This is free and unencumbered software released into the public domain.

module FFIDB
  module Symbolic
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
