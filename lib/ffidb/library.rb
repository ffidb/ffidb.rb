# This is free and unencumbered software released into the public domain.

require_relative 'library_parser'
require_relative 'symbol_table'

require 'pathname'
require 'yaml'

module FFIDB
  class Library
    include SymbolTable
    include Comparable

    attr_reader :name
    attr_reader :version
    attr_reader :path

    attr_reader :summary
    attr_reader :website
    attr_reader :source
    attr_reader :packages
    attr_reader :dlopen
    attr_reader :objects
    attr_reader :headers

    ##
    # @param  [Library] other
    # @return [Integer]
    def <=>(other) self.name <=> other&.name end # FIXME

    ##
    # @param [String, #to_s] name
    # @param [String, #to_s] version
    # @param [Pathname, #to_s] path
    def initialize(name, version, path)
      @name, @version = name.to_s.freeze, (version || :stable).to_s.freeze
      @path = Pathname(path).freeze
      if (metadata_path = @path.join('library.yaml')).exist?
        metadata  = YAML.load(metadata_path.read).transform_keys(&:to_sym)
        metadata.delete(:name)
        @summary  = metadata.delete(:summary).freeze
        @website  = metadata.delete(:website).freeze
        @source   = metadata.delete(:source).freeze
        @packages = metadata.delete(:packages).transform_keys(&:to_sym).freeze
        dlopen    = metadata.delete(:dlopen).freeze
        @dlopen   = dlopen.is_a?(Array) ? dlopen : [dlopen]
        @objects  = (metadata.delete(:objects) || []).freeze
        @headers  = (metadata.delete(:headers) || []).freeze
      end
    end

    ##
    # @return [String]
    def soname() self.objects&.first end

    ##
    # @yield  [typedef]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_typedef(&block)
      return self.to_enum(:each_typedef) unless block_given?
      self.each_symbol.filter { |symbol| symbol.typedef? }.each(&block)
    end

    ##
    # @yield  [enum]
    # @yieldparam [enum] Enum
    # @return [Enumerator]
    def each_enum(&block)
      return self.to_enum(:each_enum) unless block_given?
      self.each_symbol.filter { |symbol| symbol.enum? }.each(&block)
    end

    ##
    # @yield  [struct]
    # @yieldparam [struct] Struct
    # @return [Enumerator]
    def each_struct(&block)
      return self.to_enum(:each_struct) unless block_given?
      self.each_symbol.filter { |symbol| symbol.struct? }.each(&block)
    end

    ##
    # @yield  [union]
    # @yieldparam [union] Union
    # @return [Enumerator]
    def each_union(&block)
      return self.to_enum(:each_union) unless block_given?
      self.each_symbol.filter { |symbol| symbol.union? }.each(&block)
    end

    ##
    # @yield  [function]
    # @yieldparam [function] Function
    # @return [Enumerator]
    def each_function(&block)
      return self.to_enum(:each_function) unless block_given?
      self.each_symbol.filter { |symbol| symbol.function? }.each(&block)
    end

    ##
    # @yield  [symbol]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_symbol(&block)
      return self.to_enum(:each_symbol) unless block_given?
      LibraryParser.new(self.path.join(self.version)).each_symbol(&block)
    end
  end # Library
end # FFIDB
