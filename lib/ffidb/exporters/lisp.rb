# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Common Lisp programming language (using CFFI).
  #
  # @see https://common-lisp.net/project/cffi/
  class Lisp < FFIDB::Exporter
    # @see https://common-lisp.net/project/cffi/manual/html_node/Foreign-Types.html
    TYPE_MAP = {
      'void'               => :void,
      # standard signed-integer types:
      'char'               => :char,
      'short'              => :short,
      'int'                => :int,
      'long'               => :long,
      'long long'          => :llong,
      # standard unsigned-integer types:
      'unsigned char'      => :uchar,
      'unsigned short'     => :ushort,
      'unsigned int'       => :uint,
      'unsigned long'      => :ulong,
      'unsigned long long' => :ullong,
      # standard floating-point types:
      'float'              => :float,
      'double'             => :double,
      'long double'        => :'long-double',
      # standard character-sequence types:
      'char *'             => :string,
      'const char *'       => :string,
      # <stdarg.h>
      'va_list'            => :pointer,
      # <stdbool.h>
      '_Bool'              => :bool,
      # <stddef.h>
      'size_t'             => :'size-t',
      'wchar_t'            => :int,  # TODO: https://stackoverflow.com/a/13510080
      # <stdint.h>
      'int8_t'             => :int8,
      'int16_t'            => :int16,
      'int32_t'            => :int32,
      'int64_t'            => :int64,
      'uint8_t'            => :uint8,
      'uint16_t'           => :uint16,
      'uint32_t'           => :uint32,
      'uint64_t'           => :uint64,
      'intptr_t'           => :pointer,
      'uintptr_t'          => :pointer,
      # <sys/types.h>
      'ssize_t'            => :long,  # TODO
      'off_t'              => :ulong, # TODO
      # all other types:
      nil                  => :pointer,
    }

    def begin
      puts "; #{FFIDB.header}"
      puts
      @package = self.options[:module] # TODO: use as package name
      puts "(asdf:load-system :cffi)"
    end

    def begin_library(library)
      @library = library
      soname = self.dlopen_paths_for(library).first # FIXME
      puts
      puts <<~EOS
      (cffi:define-foreign-library #{@library.name}
        (t (:default "#{soname}")))

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
    # @param  [FFIDB::Type] c_type
    # @return [Symbol]
    def cffi_type(c_type)
      TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
    end
  end # Lisp
end # FFIDB::Exporters
