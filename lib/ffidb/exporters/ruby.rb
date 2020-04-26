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
      'intptr_t'           => :pointer,
      'uintptr_t'          => :pointer,
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
      # standard character-sequence types:
      'char *'             => :string,
      'const char *'       => :string,
      # miscellaneous types:
      nil                  => :pointer,
    }

    def begin
      puts "# #{FFIDB.header}"
      puts
      puts "require 'ffi'"
    end

    def begin_library(library)
      @library = library
      puts
      puts <<~EOS
      module #{library.name.capitalize}
        extend FFI::Library
        ffi_lib [#{library.objects.map(&:inspect).join(', ')}, "#{library.dlopen}"]
      EOS
      puts
    end

    def finish_library
      puts "end # #{@library.name.capitalize}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| rb_type(p.type).inspect }
      puts "  attach_function :#{function.name}, [#{parameters.join(', ')}], :#{rb_type(function.type)}"
    end

    protected

    ##
    # @param  [String, #to_s] c_type
    # @return [Symbol]
    def rb_type(c_type)
      TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
    end
  end # Ruby
end # FFIDB::Exporters
