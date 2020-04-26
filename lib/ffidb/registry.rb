# This is free and unencumbered software released into the public domain.

require_relative 'errors'

require 'pathname'

module FFIDB
  class Registry
    GIT_HTTPS_URL = 'https://github.com/ffidb/ffidb.git'.freeze

    attr_reader :path

    ##
    # @return [Pathname]
    def self.default_path
      Pathname(ENV['HOME']).join('.ffidb')
    end

    ##
    # @param [Pathname, #to_s] path
    def self.open(path = nil, &block)
      registry = self.new(path)
      block_given? ? block.call(registry) : registry
    end

    ##
    # @param [Pathname, #to_s] path
    # @raise [RegistryVersionMismatch] if this version of FFIDB.rb is unable to open the registry
    def initialize(path = nil)
      @path = Pathname(path || self.class.default_path)

      if (version_file = @path.join('.cli-version')).exist?
        min_version = version_file.read.chomp.split('.').map(&:to_i)
        if (FFIDB::VERSION.to_a <=> min_version).negative?
          raise RegistryVersionMismatch, "FFIDB.rb #{min_version.join('.')}+ is required for the registry directory #{@path}"
        end
      end
    end

    ##
    # @yield  [library]
    # @return [Enumerator]
    def each_library(&block)
      return self.to_enum(:each_library) unless block_given?
      library_names = self.path.glob('*')
        .select { |path| path.directory? }
        .map { |path| path.basename.to_s }
        .sort
      library_names.each do |library_name|
        yield self.open_library(library_name)
      end
    end

    ##
    # @param  [String, #to_s] library_name
    # @param  [String, #to_s] library_version
    # @yield  [library]
    # @return [Library]
    def open_library(library_name, library_version = nil, &block)
      library_path = self.path.join(library_name.to_s)
      return nil unless library_path.directory?
      library = Library.new(library_name, library_version, library_path)
      block_given? ? block.call(library) : library
    end

    ##
    # @param  [String, Regexp] keyword
    # @yield  [function]
    # @yield  [library]
    # @return [Enumerator]
    def find_functions(keyword, &block)
      return self.to_enum(:find_functions) unless block_given?
      count = 0
      self.each_library do |library|
        library.each_function do |function|
          if keyword === function.name
            count += 1
            yield function, library
          end
        end
      end
      count > 0 ? count : nil
    end
  end # Registry
end # FFIDB
