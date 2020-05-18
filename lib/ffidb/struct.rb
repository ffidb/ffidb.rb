# This is free and unencumbered software released into the public domain.

module FFIDB
  class Struct < ::Struct.new(:name, :comment)
    include Comparable

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [String, #to_s] comment
    def initialize(name, comment: nil)
      super(name.to_sym, comment ? comment.to_s : nil)
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
      "struct #{self.name}"
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
      YAML.dump(h).gsub!("---\n", "--- !struct\n")
    end
  end # Struct
end # FFIDB
