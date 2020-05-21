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

    def finish
      puts self.render_template('lisp.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#inspect]
    def struct_type(c_type)
      case
        when c_type.array? then [c_type.array_type.to_s.to_sym, :count, c_type.array_size]
        else [self.param_type(c_type)]
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#inspect]
    def param_type(c_type)
      case
        when c_type.enum? then :int
        else TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
      end
    end
  end # Lisp
end # FFIDB::Exporters
