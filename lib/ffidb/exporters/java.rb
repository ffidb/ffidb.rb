# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Java programming language (using JNA).
  #
  # @see https://github.com/java-native-access/jna/blob/master/www/GettingStarted.md
  class Java < FFIDB::Exporter
    TYPE_MAP = ::YAML.load(File.read(File.expand_path("../../../etc/mappings/java.yaml", __dir__)))
      .freeze

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
    # @return [#to_s]
    def param_type(c_type)
      case
        when c_type.enum? then :int
        else TYPE_MAP[c_type.to_s] || TYPE_MAP['void *']
      end
    end
    alias_method :struct_type, :param_type
  end # Java
end # FFIDB::Exporters
