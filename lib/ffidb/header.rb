# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Header < Struct.new(:name, :comment, :functions, keyword_init: true)
    include Comparable

    ##
    # @param  [Pathname, #to_s] path
    # @param  [Pathname, #to_s] base_directory
    # @return [Header]
    def self.parse(path, base_directory: nil)
      path = Pathname(path.to_s) unless path.is_a?(Pathname)
      name = (base_directory ? path.relative_path_from(base_directory) : path).to_s

      require 'ffi/clang' # https://rubygems.org/gems/ffi-clang

      index = FFI::Clang::Index.new
      translation_unit = index.parse_translation_unit(path.to_s)
      declarations = translation_unit.cursor.select(&:declaration?)
      comment = translation_unit.cursor.comment&.text

      header = self.new(name: name, comment: comment, functions: [])
      while declaration = declarations.shift
        location = declaration.location
        comment = declaration.comment
        case declaration.kind
          when :cursor_function
            function = FFIDB::Function.parse_declaration(declaration, base_directory: base_directory)
            while declaration = declarations.shift
              case declaration.kind
                 when :cursor_parm_decl
                   function.parameters << FFIDB::Parameter.parse_declaration(declaration)
                 else break
              end
            end
            function.parameters.freeze
            header.functions << function
          else # TODO: other declarations of interest?
        end
      end

      header
    end

    ##
    # @param  [Header] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end
  end # Header
end # FFIDB
