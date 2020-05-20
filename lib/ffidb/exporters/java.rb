# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Java programming language (using JNA).
  #
  # @see https://github.com/java-native-access/jna/blob/master/www/GettingStarted.md
  class Java < FFIDB::Exporter
    # @see https://github.com/java-native-access/jna/blob/master/www/Mappings.md
    # @see https://java-native-access.github.io/jna/5.5.0/javadoc/overview-summary.html#marshalling
    TYPE_MAP = {
      'void'               => :void,
      # standard signed-integer types:
      'char'               => :byte,
      'short'              => :short,
      'int'                => :int,
      'long'               => :NativeLong,
      'long long'          => :long,
      # standard unsigned-integer types:
      'unsigned char'      => :byte,
      'unsigned short'     => :short,
      'unsigned int'       => :int,
      'unsigned long'      => :NativeLong,
      'unsigned long long' => :long,
      # standard floating-point types:
      'float'              => :float,
      'double'             => :double,
      'long double'        => nil, # https://github.com/java-native-access/jna/issues/860
      # standard character-sequence types:
      'char *'             => :String,
      'const char *'       => :String,
      # <stdarg.h>
      'va_list'            => :Pointer,
      # <stdbool.h>
      '_Bool'              => :boolean,
      # <stddef.h>
      'size_t'             => :size_t, # https://github.com/java-native-access/jna/issues/1113
      'wchar_t'            => :char,
      # <stdint.h>
      'int8_t'             => :byte,
      'int16_t'            => :short,
      'int32_t'            => :int,
      'int64_t'            => :long,
      'uint8_t'            => :byte,
      'uint16_t'           => :short,
      'uint32_t'           => :int,
      'uint64_t'           => :long,
      'intptr_t'           => :Pointer,
      'uintptr_t'          => :Pointer,
      # <sys/types.h>
      'ssize_t'            => :ssize_t,
      'off_t'              => :size_t, # TODO
      # all other types:
      nil                  => :Pointer,
    }

    def begin_library(library)
      interface_name = self.options[:module] || library.name.capitalize
      library.define_singleton_method(:interface_name) { interface_name }
      super(library)
    end

    def finish
      puts self.render_template('java.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [Symbol]
    def param_type(c_type)
      case
        when c_type.enum? then :int
        else TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
      end
    end
    alias_method :struct_type, :param_type
  end # Java
end # FFIDB::Exporters
