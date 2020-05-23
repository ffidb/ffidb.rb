# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Python programming language (using ctypes).
  #
  # @see https://docs.python.org/3/library/ctypes.html
  class Python < FFIDB::Exporter
    TYPE_MAP = 'python.yaml'

    def finish
      puts self.render_template('python.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def struct_type(c_type)
      case
        when c_type.array? then [self.param_type(c_type.array_type), '*', c_type.array_size].join(' ')
        else self.param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def param_type(c_type)
      case py_type = super(c_type)
        when 'None' then py_type
        else "ctypes.#{py_type}"
      end
    end
  end # Python
end # FFIDB::Exporters
