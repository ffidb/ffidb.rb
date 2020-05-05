# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Dart programming language.
  #
  # @see https://dart.dev/guides/libraries/c-interop
  # @see https://flutter.dev/docs/development/platform-integration/c-interop
  # @see https://api.dart.dev/dev/dart-ffi/dart-ffi-library.html
  class Dart < FFIDB::Exporter
    # @see https://api.dart.dev/dev/dart-ffi/dart-ffi-library.html
    TYPE_MAP_FFI = {
      'void'               => :Void,
      # standard signed-integer types:
      'char'               => :Int8,
      'short'              => :Int16,
      'int'                => :Int32,
      'long'               => :Int64,  # TODO
      'long long'          => :Int64,
      # standard unsigned-integer types:
      'unsigned char'      => :Uint8,
      'unsigned short'     => :Uint16,
      'unsigned int'       => :Uint32,
      'unsigned long'      => :Uint64, # TODO
      'unsigned long long' => :Uint64,
      # standard floating-point types:
      'float'              => :Float,
      'double'             => :Double,
      'long double'        => nil, # not supported
      # standard character-sequence types:
      'char *'             => 'Pointer<ffi.Int8>', # TODO: Utf8
      'const char *'       => 'Pointer<ffi.Int8>', # TODO: Utf8
      # <stdarg.h>
      'va_list'            => 'Pointer<ffi.Void>',
      # <stdbool.h>
      '_Bool'              => :Int8,   # TODO
      # <stddef.h>
      'size_t'             => :Uint64, # TODO
      'wchar_t'            => :Int32,  # TODO
      # <stdint.h>
      'int8_t'             => :Int8,
      'int16_t'            => :Int16,
      'int32_t'            => :Int32,
      'int64_t'            => :Int64,
      'uint8_t'            => :Uint8,
      'uint16_t'           => :Uint16,
      'uint32_t'           => :Uint32,
      'uint64_t'           => :Uint64,
      'intptr_t'           => :IntPtr,
      'uintptr_t'          => :IntPtr,
      # <sys/types.h>
      'ssize_t'            => :Int64,  # TODO
      'off_t'              => :Uint64, # TODO
      # all other types:
      nil                  => 'Pointer<ffi.Void>',
    }

    # @see https://dart.dev/guides/language/language-tour
    TYPE_MAP_DART = {
      'void'               => :void,
      # standard signed-integer types:
      'char'               => :int,
      'short'              => :int,
      'int'                => :int,
      'long'               => :int,
      'long long'          => :int,
      # standard unsigned-integer types:
      'unsigned char'      => :int,
      'unsigned short'     => :int,
      'unsigned int'       => :int,
      'unsigned long'      => :int,
      'unsigned long long' => :int,
      # standard floating-point types:
      'float'              => :double,
      'double'             => :double,
      # <stdbool.h>
      '_Bool'              => :bool,
      # all other types:
      nil                  => nil,
    }

    def begin
      puts "// #{FFIDB.header}" if self.header?
      puts if self.header?
      puts <<~EOS
      import 'dart:ffi' as ffi;
      import 'dart:io' as io;
      EOS
    end

    def begin_library(library)
      @library = library
      soname = self.dlopen_paths_for(library).first # FIXME
      puts
      puts <<~EOS
      final #{@library.name} = ffi.DynamicLibrary.open('#{soname}');
      EOS
    end

    def export_function(function)
      dart_parameters = function.parameters.each_value.map { |p| dart_type(p.type) }
      ffi_parameters = function.parameters.each_value.map { |p| ffi_type(p.type) }
      puts
      puts <<~EOS
      final #{dart_type(function.type)} Function(#{dart_parameters.join(', ')}) #{function.name} = #{@library.name}
          .lookup<ffi.NativeFunction<#{ffi_type(function.type)} Function(#{ffi_parameters.join(', ')})>>('#{function.name}')
          .asFunction();
      EOS
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def dart_type(c_type)
      case
        when c_type.enum? then :int
        else TYPE_MAP_DART[c_type.to_s] || self.ffi_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def ffi_type(c_type)
      ffi_type = case
        when c_type.enum? then :Int32
        else TYPE_MAP_FFI[c_type.to_s] || TYPE_MAP_FFI[nil]
      end
      "ffi.#{ffi_type}"
    end
  end # Dart
end # FFIDB::Exporters
