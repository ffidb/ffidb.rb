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
    TYPE_MAP = 'dart.yaml'

    # @see https://dart.dev/guides/language/language-tour
    TYPE_MAP_DART = {
      'Void'          => :void,
      'Int8'          => :int,
      'Int16'         => :int,
      'Int32'         => :int,
      'Int64'         => :int,
      'Uint8'         => :int,
      'Uint16'        => :int,
      'Uint32'        => :int,
      'Uint64'        => :int,
      'Float'         => :double,
      'Double'        => :double,
      'IntPtr'        => :int,
      'Pointer<Int8>' => 'Pointer<Int8>',
      'Pointer<Void>' => 'Pointer<Void>',
    }

    def finish
      puts self.render_template('dart.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def dart_struct_type(c_type)
      case
        when c_type.array? then self.dart_param_type(c_type) # TODO: https://github.com/dart-lang/sdk/issues/35763
        else self.dart_param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def ffi_struct_type(c_type)
      case
        when c_type.array? then self.ffi_param_type(c_type) # TODO: https://github.com/dart-lang/sdk/issues/35763
        else self.ffi_param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def dart_param_type(c_type)
      case
        when c_type.array?
          "Pointer<#{self.dart_param_type(c_type.array_type)}>"
        when type = TYPE_MAP_DART[self.ffi_param_type(c_type)] then type
        else TYPE_MAP_DART[self.typemap['int']].to_s
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def ffi_param_type(c_type)
      case
        when c_type.array?
          "Pointer<#{self.ffi_param_type(c_type.array_type)}>"
        else self.param_type(c_type)
      end
    end
  end # Dart
end # FFIDB::Exporters
