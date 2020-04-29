# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Parser
    attr_reader :base_directory
    attr_reader :debug
    attr_reader :defines
    attr_reader :include_paths

    ##
    # @param [Pathname, #to_s] base_directory
    def initialize(base_directory: nil, debug: nil)
      require 'ffi/clang' # https://rubygems.org/gems/ffi-clang

      @base_directory = base_directory
      @debug = debug
      @defines = {}
      @include_paths = []
      @clang_index = FFI::Clang::Index.new
    end

    ##
    # @param  [String, #to_s] var_and_val
    # @return [void]
    def parse_macro!(var_and_val)
      var, val = var_and_val.to_s.split('=', 2)
      val = 1 if val.nil?
      self.define_macro! var, val
    end

    ##
    # @param  [Symbol, #to_sym] var
    # @param  [String, #to_s] val
    # @return [void]
    def define_macro!(var, val = 1)
      self.defines[var.to_sym] = val.to_s
    end

    ##
    # @param  [Pathname, #to_s] path
    # @return [void]
    def add_include_path!(path)
      self.include_paths << Pathname(path)
    end

    ##
    # @param  [Pathname, #to_s] path
    # @yield  [exception]
    # @return [Header]
    def parse_header(path)
      path = Pathname(path.to_s) unless path.is_a?(Pathname)
      name = (self.base_directory ? path.relative_path_from(self.base_directory) : path).to_s
      args = self.defines.inject([]) { |r, (k, v)| r << "-D#{k}=#{v}" }
      args += self.include_paths.map { |p| "-I#{p}" }

      translation_unit = @clang_index.parse_translation_unit(path.to_s, args)
      translation_unit.diagnostics.each do |diagnostic|
        exception = case diagnostic.severity.to_sym
          when :fatal then ParseError.new(diagnostic.format)
          when :warning then ParseWarning.new(diagnostic.format)
          else ParseWarning.new(diagnostic.format)
        end
        yield exception
      end

      base_directory_str = base_directory.to_s.freeze
      FFIDB::Header.new(name: name, functions: []).tap do |header|
        root_cursor = translation_unit.cursor
        root_cursor.visit_children do |declaration, _|
          location = declaration.location
          case declaration.kind
            when :cursor_function
              if location.file.start_with?(base_directory_str)
                function = self.parse_function(declaration)
                function.definition = self.parse_location(location)
                header.functions << function
              end
            else # TODO: other declarations of interest?
          end
          :continue # visit the next sibling
        end
        header.comment = root_cursor.comment&.text
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
        definition: nil, # set in #parse_header()
        comment: comment && !(comment.empty?) ? comment : nil,
      )
      declaration.visit_children do |child_declaration, _|
        if child_declaration.kind == :cursor_parm_decl
          default_name = "_#{function.parameters.size + 1}"
          parameter = self.parse_parameter(child_declaration, default_name: default_name)
          function.parameters[parameter.name.to_sym] = parameter
        end
        :continue # visit the next sibling
      end
      function.parameters.freeze
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
        when 'size_t', 'wchar_t' then ostensible_type               # <stddef.h>
        when /^u?int\d+_t$/, /^u?int\d+_t \*$/ then ostensible_type # <stdint.h>
        when /^u?intptr_t$/ then ostensible_type                    # <stdint.h>
        when 'ssize_t', 'off_t', 'off64_t' then ostensible_type     # <sys/types.h>
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
