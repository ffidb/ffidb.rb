# This is free and unencumbered software released into the public domain.

module FFIDB
  class Type < ::Struct.new(:spec)
    include Comparable

    ##
    # @param  [String, #to_s] spec
    # @return [Type]
    def self.for(type_spec)
      return type_spec if type_spec.is_a?(Type)
      self.new(type_spec)
    end

    ##
    # @param [String, #to_s] spec
    def initialize(spec)
      super(spec.to_s)
    end

    ##
    # @param  [Type] other
    # @return [Integer]
    def <=>(other) self.spec <=> other.spec end

    ##
    # @return [Symbol]
    def tag
      case self.spec.gsub(/^const /, '')
        when 'enum', /^enum\s+/ then :enum
        when 'struct', /^struct\s+/ then :struct
        when 'union', /^union\s+/ then :union
        else nil
      end
    end

    ##
    # @return [Symbol]
    def name
      self.spec.gsub(/\s*\*+$/, '').to_sym # TODO
    end

    ##
    # @return [Boolean]
    def const_qualified?
      self.spec.start_with?('const ')
    end

    ##
    # @return [Boolean]
    def atomic?
      self.bool? || self.integer? || self.floating_point? || self.pointer? || nil # TODO
    end

    ##
    # @return [Boolean]
    def void?
      self.spec == 'void'
    end

    ##
    # @return [Boolean]
    def bool?
      self.spec == '_Bool'
    end

    ##
    # @return [Boolean]
    def enum?
      !(self.pointer?) && (self.spec == 'enum' || self.spec.start_with?('enum '))
    end

    ##
    # @return [Boolean]
    def struct?
      !(self.pointer?) && (self.spec == 'struct' || self.spec.start_with?('struct ') || self.spec.start_with?('const struct '))
    end

    ##
    # @return [Boolean]
    def union?
      !(self.pointer?) && (self.spec.start_with?('union ') || self.spec.start_with?('const union '))
    end

    ##
    # @return [Boolean]
    def integer?
      case self.spec
        when 'char', 'short', 'int', 'long', 'long long' then true
        when 'unsigned char', 'unsigned short', 'unsigned int', 'unsigned long', 'unsigned long long' then true
        when 'size_t', 'wchar_t' then true # <stddef.h>
        when 'ssize_t', 'off_t' then true  # <sys/types.h>
        when /^u?int\d+_t$/ then true
        else false
      end
    end

    ##
    # @return [Boolean]
    def signed_integer?
      return false unless self.integer?
      case self.spec
        when 'char', 'short', 'int', 'long', 'long long' then true
        when 'wchar_t' then nil  # <stddef.h>
        when 'ssize_t' then true # <sys/types.h>
        when /^int\d+_t$/ then true
        else false
      end
    end

    ##
    # @return [Boolean]
    def unsigned_integer?
      return false unless self.integer?
      return true if self.spec.start_with?('u')
      case self.spec
        when 'unsigned char', 'unsigned short', 'unsigned int', 'unsigned long', 'unsigned long long' then true
        when 'size_t' then true # <stddef.h>
        when 'wchar_t' then nil # <stddef.h>
        when 'off_t' then true  # <sys/types.h>
        when /^uint\d+_t$/ then true
        else false
      end
    end

    ##
    # @return [Boolean]
    def floating_point?
      case self.spec
        when 'float', 'double', 'long double' then true
        else false
      end
    end

    ##
    # @return [Boolean]
    def array?
      self.spec.include?('[')
    end

    ##
    # @return [Type]
    def array_type
      if self.array?
        self.class.for(self.spec.gsub(/\s+(\[[^\]]+\])/, ''))
      end
    end

    ##
    # @return [Integer]
    def array_size
      if self.array?
        (/\[([^\]]+)\]/ =~ self.spec) && $1.to_i
      end
    end

    ##
    # @return [Boolean]
    def pointer?
      self.spec.end_with?('*') ||
      self.array_pointer?      ||
      self.function_pointer?   ||
      case self.spec
        when 'intptr_t', 'uintptr_t' then true
        when 'va_list' then true
        else false
      end
    end

    ##
    # @return [Boolean]
    def array_pointer?
      self.spec.end_with?('[]')
    end

    ##
    # @return [Boolean]
    def enum_pointer?
      self.pointer? && self.spec.start_with?('enum ')
    end

    ##
    # @return [Boolean]
    def struct_pointer?
      self.pointer? && (self.spec.start_with?('struct ') || self.spec.start_with?('const struct '))
    end

    ##
    # @return [Boolean]
    def union_pointer?
      self.pointer? && (self.spec.start_with?('union ') || self.spec.start_with?('const union '))
    end

    ##
    # @return [Boolean]
    def function_pointer?
      self.spec.include?('(*)')
    end

    ##
    # @return [String]
    def to_s
      self.spec
    end

    ##
    # @return [Hash<Symbol, Object>]
    def to_h
      {spec: self.spec}
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{self.spec.inspect})"
    end

    protected

    ##
    # @return [Integer, Range, nil]
    def sizeof
      nil # TODO
    end
    alias_method :size, :sizeof

    ##
    # @return [Integer, Range, nil]
    def alignof
      nil # TODO
    end
  end # Type
end # FFIDB
