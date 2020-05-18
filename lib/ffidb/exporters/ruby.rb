# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Ruby programming language (using FFI).
  #
  # @see https://github.com/ffi/ffi/wiki
  class Ruby < FFIDB::Exporter
    # @see https://github.com/ffi/ffi/wiki/Types
    TYPE_MAP = {
      'void'               => :void,
      # standard signed-integer types:
      'char'               => :char,
      'short'              => :short,
      'int'                => :int,
      'long'               => :long,
      'long long'          => :long_long,
      # standard unsigned-integer types:
      'unsigned char'      => :uchar,
      'unsigned short'     => :ushort,
      'unsigned int'       => :uint,
      'unsigned long'      => :ulong,
      'unsigned long long' => :ulong_long,
      # standard floating-point types:
      'float'              => :float,
      'double'             => :double,
      'long double'        => :long_double,
      # standard character-sequence types:
      'char *'             => :string,
      'const char *'       => :string,
      # <stdarg.h>
      'va_list'            => :pointer,
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
      'intptr_t'           => :pointer,
      'uintptr_t'          => :pointer,
      # <sys/types.h>
      'ssize_t'            => :ssize_t,
      'off_t'              => :off_t,
      # all other types:
      nil                  => :pointer,
    }

    def begin_library(library)
      @library = library
      @module = self.options[:module] || library.name.capitalize
      @library_paths = self.dlopen_paths_for(library)
    end

    def finish_library
      puts self.render_template('ruby.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [Symbol]
    def rb_type(c_type)
      case
        when c_type.enum? then :int
        else TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
      end
    end
  end # Ruby
end # FFIDB::Exporters
