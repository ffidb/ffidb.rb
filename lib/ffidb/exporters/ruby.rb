# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Ruby programming language (using FFI).
  #
  # @see https://github.com/ffi/ffi/wiki
  class Ruby < FFIDB::Exporter
    TYPE_MAP = ::YAML.load(File.read(File.expand_path("../../../etc/mappings/ruby.yaml", __dir__)))
      .transform_values(&:to_sym)
      .freeze

    def finish
      puts self.render_template('ruby.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#inspect]
    def struct_type(c_type)
      case
        when c_type.array? then [self.param_type(c_type.array_type), c_type.array_size]
        else self.param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#inspect]
    def param_type(c_type)
      case
        when c_type.enum? then TYPE_MAP['int']
        when c_type.pointer? then TYPE_MAP['void *']
        when c_type.array? then TYPE_MAP['void *']
        else TYPE_MAP[c_type.to_s] || TYPE_MAP['int']
      end
    end
  end # Ruby
end # FFIDB::Exporters
