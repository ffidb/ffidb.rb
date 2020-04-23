# This is free and unencumbered software released into the public domain.

module FFIDB
  class Function < Struct.new(:name, :type, :file, :line, :comment, :parameters, keyword_init: true)
    ##
    # @param [FFI::Clang::Cursor] declaration
    def self.parse_declaration(declaration)
      location = declaration.location
      comment = declaration.comment
      self.new(
        name: declaration.spelling,
        type: declaration.type.spelling,
        file: location&.file,
        line: location&.line,
        comment: comment&.text,
        parameters: [], # TODO: parse parameter declarations
      )
    end
  end # Function
end # FFIDB
