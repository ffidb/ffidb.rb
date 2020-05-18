# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Python programming language (using ctypes).
  #
  # @see https://docs.python.org/3/library/ctypes.html
  class Python < FFIDB::Exporter
    # @see https://docs.python.org/3/library/ctypes.html
    TYPE_MAP = {
      'void'               => :None,
      # standard signed-integer types:
      'char'               => :char,
      'short'              => :short,
      'int'                => :int,
      'long'               => :long,
      'long long'          => :longlong,
      # standard unsigned-integer types:
      'unsigned char'      => :ubyte,
      'unsigned short'     => :ushort,
      'unsigned int'       => :uint,
      'unsigned long'      => :ulong,
      'unsigned long long' => :ulonglong,
      # standard floating-point types:
      'float'              => :float,
      'double'             => :double,
      'long double'        => :longdouble,
      # standard character-sequence types:
      'char *'             => :char_p,
      'const char *'       => :char_p,
      # <stdarg.h>
      'va_list'            => :void_p,
      # <stdbool.h>
      '_Bool'              => :bool,
      # <stddef.h>
      'size_t'             => :size_t,
      'wchar_t'            => :wchar_t,
      # <stdint.h>
      'int8_t'             => :int8,
      'int16_t'            => :int16,
      'int32_t'            => :int32,
      'int64_t'            => :int64,
      'uint8_t'            => :uint8,
      'uint16_t'           => :uint16,
      'uint32_t'           => :uint32,
      'uint64_t'           => :uint64,
      'intptr_t'           => :void_p,
      'uintptr_t'          => :void_p,
      # <sys/types.h>
      'ssize_t'            => :ssize_t,
      'off_t'              => :size_t, # TODO: https://stackoverflow.com/q/43671524
      # all other types:
      nil                  => :void_p,
    }

    def begin_library(library)
      @library = library
    end

    def finish_library
      puts self.render_template('python.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def py_type(c_type)
      case
        when c_type.enum? then 'ctypes.c_int'
        else case py_type = TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
          when :None then py_type.to_s
          else "ctypes.c_#{py_type}"
        end
      end
    end
  end # Python
end # FFIDB::Exporters
