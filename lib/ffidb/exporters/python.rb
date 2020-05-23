# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Python programming language (using ctypes).
  #
  # @see https://docs.python.org/3/library/ctypes.html
  class Python < FFIDB::Exporter
    TYPE_MAP = ::YAML.load(File.read(File.expand_path("../../../etc/mappings/python.yaml", __dir__)))
      .freeze

    def finish
      puts self.render_template('python.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def struct_type(c_type)
      case
        when c_type.array? then [self.param_type(c_type.array_type), '*', c_type.array_size].join(' ')
        else self.param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [#to_s]
    def param_type(c_type)
      case
        when c_type.enum? then TYPE_MAP['int']
        when c_type.pointer? then TYPE_MAP['void *']
        when c_type.array? then TYPE_MAP['void *']
        else case py_type = TYPE_MAP[c_type.to_s] || TYPE_MAP['int']
          when 'None' then py_type
          else "ctypes.#{py_type}"
        end
      end
    end
  end # Python
end # FFIDB::Exporters
