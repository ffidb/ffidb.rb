# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Java programming language (using JNA).
  #
  # @see https://github.com/java-native-access/jna/blob/master/www/GettingStarted.md
  class Java < FFIDB::Exporter
    TYPE_MAP = 'java.yaml'

    def begin_library(library)
      if library
        interface_name = self.options[:module] || library.name.capitalize
        library.define_singleton_method(:interface_name) { interface_name }
      end
      super(library)
    end

    def finish
      puts self.render_template('java.erb')
    end
  end # Java
end # FFIDB::Exporters
