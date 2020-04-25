# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Parser
    attr_reader :base_directory
    attr_reader :defines

    ##
    # @param [Pathname, #to_s] base_directory
    def initialize(base_directory: nil)
      require 'ffi/clang' # https://rubygems.org/gems/ffi-clang

      @base_directory = base_directory
      @defines = {}
      @clang_index = FFI::Clang::Index.new
    end

    ##
    # @param  [Symbol, #to_sym] var
    # @param  [String, #to_s] val
    # @return [void]
    def define!(var, val = 1)
      self.defines[var.to_sym] = val.to_s
    end

    ##
    # @param  [Pathname, #to_s] path
    # @return [void]
    def parse_header(path)
      path = Pathname(path.to_s) unless path.is_a?(Pathname)
      name = (self.base_directory ? path.relative_path_from(self.base_directory) : path).to_s
      args = self.defines.inject([]) { |r, (k, v)| r << "-D#{k}=#{v}" }

      translation_unit = @clang_index.parse_translation_unit(path.to_s, args)
      declarations = translation_unit.cursor.select(&:declaration?)
      comment = translation_unit.cursor.comment&.text

      FFIDB::Header.new(name: name, comment: comment, functions: []).tap do |header|
        while declaration = declarations.shift
          location = declaration.location
          comment = declaration.comment
          case declaration.kind
            when :cursor_function
              function = self.parse_function(declaration)
              while declaration = declarations.shift
                case declaration.kind
                   when :cursor_parm_decl
                     default_name = "_#{function.parameters.size + 1}"
                     function.parameters << self.parse_parameter(declaration, default_name: default_name)
                   else break
                end
              end
              function.parameters.freeze
              header.functions << function
            else # TODO: other declarations of interest?
          end
        end
      end
    end

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @return [Function]
    def parse_function(declaration)
      FFIDB::Function.new(
        name: declaration.spelling,
        type: declaration.type.canonical.spelling,
        parameters: [],
        definition: self.parse_location(declaration.location),
        comment: declaration.comment&.text,
      )
    end

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @param. [String, #to_s] default_name
    # @return [Parameter]
    def parse_parameter(declaration, default_name: '_')
      name = declaration.spelling
      type = declaration.type.canonical.spelling
      FFIDB::Parameter.new(
        name: (name.nil? || name.empty?) ? default_name.to_s : name,
        type: type,
      )
    end

    ##
    # @param  [FFI::Clang::ExpansionLocation] location
    # @return [Location]
    def parse_location(location)
      return nil if location.nil?
      FFIDB::Location.new(
        file: location.file ? self.make_relative_path(location.file).to_s : nil,
        line: location.line,
      )
    end

    private

    ##
    # @param  [Pathname, #to_s] path
    # @return [Pathname]
    def make_relative_path(path)
      path = Pathname(path) unless path.is_a?(Pathname)
      self.base_directory ? path.relative_path_from(self.base_directory) : path
    end
  end # Parser
end # FFIDB
