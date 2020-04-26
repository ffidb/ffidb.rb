# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Common Lisp programming language (using CFFI).
  #
  # @see https://common-lisp.net/project/cffi/
  class Lisp < FFIDB::Exporter
    def begin
      puts "; #{FFIDB.header}"
      puts
      puts "(asdf:load-system :cffi)"
    end

    def begin_library(library)
      @library = library
      puts
      puts <<~EOS
      (cffi:define-foreign-library #{@library.name}
        (t (:default "#{@library.soname}")))

      (cffi:use-foreign-library #{@library.name})
      EOS
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| "(#{p.name} :#{cffi_type(p.type)})" }
      delimiter = parameters.empty? ? '' : ' '
      puts
      puts <<~EOS
      (cffi:defcfun "#{function.name}" :#{cffi_type(function.type)}#{delimiter}#{parameters.join(' ')})
      EOS
    end

    protected

    ##
    # @param  [String] c_type
    # @return [Symbol]
    def cffi_type(c_type)
      # See: https://common-lisp.net/project/cffi/manual/html_node/Foreign-Types.html
      case c_type
        when 'void' then :void
        when '_Bool' then :bool
        when 'float', 'double' then c_type.to_sym
        when 'char', 'short', 'int', 'long' then c_type.to_sym
        when 'long long' then :llong
        when 'unsigned char' then :uchar
        when 'unsigned short' then :ushort
        when 'unsigned int' then :uint
        when 'unsigned long' then :ulong
        when 'unsigned long long' then :ullong
        when 'char *', 'const char *' then :string
        else :pointer # DEBUG: "<<<<#{c_type}>>>>"
      end
    end
  end # Lisp
end # FFIDB::Exporters
