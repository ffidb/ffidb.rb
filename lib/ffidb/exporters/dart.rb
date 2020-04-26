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
    def begin
      puts "// #{FFIDB.header}"
      puts
      puts <<~EOS
      import 'dart:ffi' as ffi;
      import 'dart:io' as io;
      EOS
    end

    def begin_library(library)
      @library = library
      puts
      puts <<~EOS
      final #{@library.name} = ffi.DynamicLibrary.open('#{@library.soname}');
      EOS
    end

    def export_function(function)
      dart_parameters = function.parameters.each_value.map { |p| dart_type(p.type) }
      ffi_parameters = function.parameters.each_value.map { |p| ffi_type(p.type) }
      puts
      puts <<~EOS
      final #{dart_type(function.type)} Function(#{dart_parameters.join(', ')}) #{function.name} = zlib
          .lookup<ffi.NativeFunction<#{ffi_type(function.type)} Function(#{ffi_parameters.join(', ')})>>('#{function.name}')
          .asFunction();
      EOS
    end

    protected

    ##
    # @param  [String] c_type
    # @return [#to_s]
    # @see https://dart.dev/guides/language/language-tour
    def dart_type(c_type)
      case c_type
        when 'void' then :void
        when '_Bool' then :bool
        when 'float', 'double' then :double
        when 'char', 'short', 'int', 'long', 'long long' then :int
        when 'unsigned char' then :int
        when 'unsigned short' then :int
        when 'unsigned int' then :int
        when 'unsigned long' then :int
        when 'unsigned long long' then :int
        else self.ffi_type(c_type)
      end
    end

    ##
    # @param  [String] c_type
    # @return [#to_s]
    # @see https://api.dart.dev/dev/dart-ffi/dart-ffi-library.html
    def ffi_type(c_type)
      ffi_type = case c_type
        when 'void' then :Void
        when '_Bool' then :Int8 # FIXME
        when 'float', 'double' then c_type.capitalize.to_sym
        when 'char' then :Int8
        when 'short' then :Int16
        when 'int' then :Int32
        when 'long' then :Int64 # FIXME
        when 'long long' then :Int64
        when 'unsigned char' then :Uint8
        when 'unsigned short' then :Uint16
        when 'unsigned int' then :Uint32
        when 'unsigned long' then :Uint64 # FIXME
        when 'unsigned long long' then :Uint64
        when 'char *', 'const char *' then 'Pointer<ffi.Int8>'
        else 'Pointer<ffi.Void>' # DEBUG: "<<<<#{c_type}>>>>"
      end
      "ffi.#{ffi_type}"
    end
  end # Dart
end # FFIDB::Exporters

# TODO: https://api.dart.dev/stable/2.8.0/dart-ffi/dart-ffi-library.html
