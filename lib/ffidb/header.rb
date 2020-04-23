# This is free and unencumbered software released into the public domain.

module FFIDB
  class Header < Struct.new(:name, :comment, :functions, keyword_init: true)
    include Comparable

    ##
    # @param [#to_s] path
    def self.parse(path)
      require 'ffi/clang' # https://rubygems.org/gems/ffi-clang

      index = FFI::Clang::Index.new
      translation_unit = index.parse_translation_unit(path.to_s)
      declarations = translation_unit.cursor.select(&:declaration?)
      comment = translation_unit.cursor.comment&.text

      header = self.new(name: path.to_s, comment: comment, functions: [])
      declarations.each do |declaration|
        location = declaration.location
        comment = declaration.comment
        case declaration.kind
          when :cursor_function
            header.functions << FFIDB::Function.parse_declaration(declaration)
          # TODO: other declarations
        end
      end

      header
    end

    ##
    # @return [Boolean]
    def <=>(other)
      self.name <=> other.name
    end
  end # Header
end # FFIDB
