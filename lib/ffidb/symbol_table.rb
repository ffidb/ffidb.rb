# This is free and unencumbered software released into the public domain.

require_relative 'symbolic'

module FFIDB
  module SymbolTable
    include Enumerable

    ##
    # @return [Array<Type>]
    def types
      self.each_type.to_a
    end

    ##
    # @yield  [type]
    # @yieldparam [type] Type
    # @return [Enumerator]
    def each_type(&block)
      return self.to_enum(:each_type) unless block_given?
      types = {}
      self.each_function do |function| # TODO: each_symbol
        types[function.type.to_s] ||= function.type
        function.parameters.each_value do |parameter|
          types[parameter.type.to_s] ||= parameter.type
        end
      end
      types.values.sort.each(&block)
    end

    ##
    # @yield  [symbol]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_symbol(&block)
      return self.to_enum(:each_symbol) unless block_given?
      self.each_typedef(&block)
      self.each_enum(&block)
      self.each_struct(&block)
      self.each_union(&block)
      self.each_function(&block)
    end
    alias_method :each, :each_symbol

    ##
    # @yield  [typedef]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_typedef(&block)
      return self.to_enum(:each_typedef) unless block_given?
      self.typedefs.each(&block)
    end

    ##
    # @yield  [enum]
    # @yieldparam [enum] Enum
    # @return [Enumerator]
    def each_enum(&block)
      return self.to_enum(:each_enum) unless block_given?
      self.enums.each(&block)
    end

    ##
    # @yield  [struct]
    # @yieldparam [struct] Struct
    # @return [Enumerator]
    def each_struct(&block)
      return self.to_enum(:each_struct) unless block_given?
      self.structs.each(&block)
    end

    ##
    # @yield  [union]
    # @yieldparam [union] Union
    # @return [Enumerator]
    def each_union(&block)
      return self.to_enum(:each_union) unless block_given?
      self.unions.each(&block)
    end

    ##
    # @yield  [function]
    # @yieldparam [function] Function
    # @return [Enumerator]
    def each_function(&block)
      return self.to_enum(:each_function) unless block_given?
      self.functions.each(&block)
    end
  end # SymbolTable
end # FFIDB
