# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Parser
    attr_reader :base_directory
    attr_reader :debug
    attr_reader :defines

    ##
    # @param [Pathname, #to_s] base_directory
    def initialize(base_directory: nil, debug: nil)
      require 'ffi/clang' # https://rubygems.org/gems/ffi-clang

      @base_directory = base_directory
      @debug = debug
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
      root_cursor = translation_unit.cursor
      comment = root_cursor.comment&.text

      FFIDB::Header.new(name: name, comment: comment, functions: []).tap do |header|
        root_cursor.visit_children do |declaration, _|
          case declaration.kind
            when :cursor_function
              function = self.parse_function(declaration)
              declaration.visit_children do |child_declaration, _|
                if child_declaration.kind == :cursor_parm_decl
                  default_name = "_#{function.parameters.size + 1}"
                  parameter = self.parse_parameter(child_declaration, default_name: default_name)
                  function.parameters[parameter.name.to_sym] = parameter
                end
                :continue # visit the next sibling
              end
              function.parameters.freeze
              header.functions << function
            else # TODO: other declarations of interest?
          end
          :continue # visit the next sibling
        end
      end
    end

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @return [Function]
    def parse_function(declaration)
      name = declaration.spelling
      comment = declaration.comment&.text
      function = FFIDB::Function.new(
        name: name,
        type: self.parse_type(declaration.type.result_type),
        parameters: {},
        definition: self.parse_location(declaration.location),
        comment: comment && !(comment.empty?) ? comment : nil,
      )
      function.instance_variable_set(:@debug, declaration.type.spelling.sub(/\s*\(/, " #{name}(")) if self.debug
      function
    end

    ##
    # @param  [FFI::Clang::Cursor] declaration
    # @param  [String, #to_s] default_name
    # @return [Parameter]
    def parse_parameter(declaration, default_name: '_')
      name = declaration.spelling
      type = self.parse_type(declaration.type)
      FFIDB::Parameter.new(
        name: ((name.nil? || name.empty?) ? default_name.to_s : name).to_sym,
        type: type,
      )
    end

    ##
    # @param  [FFI::Clang::Type] type
    # @return [String]
    def parse_type(type)
      ostensible_type = type.spelling
      canonical_type = case ostensible_type
        when '_Bool'  then ostensible_type                          # <stdbool.h>
        when 'size_t' then ostensible_type                          # <stddef.h>
        when /^u?int\d+_t$/, /^u?int\d+_t \*$/ then ostensible_type # <stdint.h>
        when /^u?intptr_t$/ then ostensible_type                    # <stdint.h>
        else type.canonical.spelling
      end
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
