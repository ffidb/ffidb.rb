# This is free and unencumbered software released into the public domain.

module FFIDB
  module Symbolic
    include Comparable

    ##
    # @param  [Symbolic] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [Symbol]
    def kind
      case
        when self.typedef? then :typedef
        when self.enum? then :enum
        when self.struct? then :struct
        when self.union? then :union
        when self.function? then :function
      end
    end

    ##
    # @return [Integer]
    def kind_weight
      case
        when self.typedef? then 1
        when self.enum? then 2
        when self.struct? then 3
        when self.union? then 4
        when self.function? then 5
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
    def union?() return false end

    ##
    # @return [Boolean]
    def function?() return false end

    ##
    # @return [String]
    def to_yaml
      h = self.to_h
      h.transform_keys!(&:to_s)
      h.transform_values! { |v| v.is_a?(Hash) ? v.transform_keys!(&:to_s) : v }
      YAML.dump(h).gsub!("---\n", "--- !#{self.kind}\n")
    end
  end # Symbolic
end # FFIDB
