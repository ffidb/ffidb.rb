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
    # @see https://github.com/dart-lang/sdk/issues/36140
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
      'char *'             => 'Pointer<Int8>', # TODO: Utf8
      'const char *'       => 'Pointer<Int8>', # TODO: Utf8
      # <stdarg.h>
      'va_list'            => 'Pointer<Void>',
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
      nil                  => 'Pointer<Void>',
    }

    # @see https://dart.dev/guides/language/language-tour
    TYPE_MAP_DART = {
      :Void                => :void,
      :Int8                => :int,
      :Int16               => :int,
      :Int32               => :int,
      :Int64               => :int,
      :Uint8               => :int,
      :Uint16              => :int,
      :Uint32              => :int,
      :Uint64              => :int,
      :Float               => :double,
      :Double              => :double,
      :IntPtr              => :int,
      'Pointer<Int8>'      => 'Pointer<Int8>',
      nil                  => 'Pointer<Void>',
    }

    def begin_library(library)
      @library = library
      @soname = self.dlopen_paths_for(library).first # FIXME
    end

    def finish
      puts self.render_template('dart.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def dart_type(c_type)
      TYPE_MAP_DART[self.ffi_type(c_type)] || TYPE_MAP_DART[nil]
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def ffi_type(c_type)
      case
        when c_type.enum? then :Int32
        else TYPE_MAP_FFI[c_type.to_s] || TYPE_MAP_FFI[nil]
      end
    end
  end # Dart
end # FFIDB::Exporters
