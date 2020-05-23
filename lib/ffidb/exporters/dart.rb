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
    TYPE_MAP_FFI = ::YAML.load(File.read(File.expand_path("../../../etc/mappings/dart.yaml", __dir__)))
      .freeze

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

    def finish
      puts self.render_template('dart.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def dart_param_type(c_type)
      TYPE_MAP_DART[self.ffi_param_type(c_type)] || TYPE_MAP_DART[nil]
    end
    alias_method :dart_struct_type, :dart_param_type

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def ffi_param_type(c_type)
      case
        when c_type.enum? then TYPE_MAP_FFI['int']
        when c_type.pointer? then TYPE_MAP_FFI['void *']
        #when c_type.array? then # TODO: https://github.com/dart-lang/sdk/issues/35763
        else TYPE_MAP_FFI[c_type.to_s] || TYPE_MAP_FFI['int']
      end
    end
    alias_method :ffi_struct_type, :ffi_param_type # TODO
  end # Dart
end # FFIDB::Exporters
