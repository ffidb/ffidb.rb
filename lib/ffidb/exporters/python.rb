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
      # <stdbool.h>
      '_Bool'              => :bool,
      # <stddef.h>
      'size_t'             => :size_t,
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
      # standard character-sequence types:
      'char *'             => :char_p,
      'const char *'       => :char_p,
      # miscellaneous types:
      nil                  => :void_p,
    }

    def begin
      puts "# #{FFIDB.header}"
      puts
      puts "import ctypes, ctypes.util"
    end

    def begin_library(library)
      @library = library
      sonames = library.objects.map { |soname| "ctypes.util.find_library('#{soname}')" }
      puts
      puts "#{library.name} = ctypes.CDLL(#{sonames.join(' or ')} or '#{library.dlopen}')"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| py_type(p.type) }
      puts
      puts <<~EOS
      #{function.name} = #{@library.name}.#{function.name}
      #{function.name}.restype = #{py_type(function.type)}
      #{function.name}.argtypes = [#{parameters.join(', ')}]
      EOS
    end

    protected

    ##
    # @param  [String, #to_s] c_type
    # @return [String]
    def py_type(c_type)
      case py_type = TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
        when :None then py_type.to_s
        else "ctypes.c_#{py_type}"
      end
    end
  end # Python
end # FFIDB::Exporters
