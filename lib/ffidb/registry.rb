# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Registry
    attr_reader :path

    ##
    # @param [Pathname, #to_s] path
    def self.open(path = nil, &block)
      registry = self.new(path)
      block_given? ? block.call(registry) : registry
    end

    ##
    # @param [Pathname, #to_s] path
    def initialize(path = nil)
      @path = Pathname(path || Pathname(ENV['HOME']).join('.ffidb'))
    end

    ##
    # @yield  [library]
    # @return [Enumerator]
    def each_library(&block)
      return self.to_enum(:each_library) unless block_given?
      # TODO
      yield self.open_library(:curl)
      yield self.open_library(:musl)
      yield self.open_library(:zlib)
    end

    ##
    # @param. [String, #to_s] name
    def open_library(name, version = nil, &block)
      library = Library.new(name, version, self.path.join(name.to_s))
      block_given? ? block.call(library) : library
    end

    ##
    # @param  [String, Regexp] keyword
    # @yield  [function]
    # @yield  [library]
    # @return [Enumerator]
    def find_functions(keyword, &block)
      return self.to_enum(:find_functions) unless block_given?
      self.each_library do |library|
        library.each_function do |function|
          yield function, library if keyword === function.name
        end
      end
    end
  end # Registry
end # FFIDB
