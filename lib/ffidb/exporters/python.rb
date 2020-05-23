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
    # @param  [Symbol, FFIDB::Type] c_type
    # @return [String]
    def struct_type(c_type)
      case c_type
        when Symbol then c_type.to_s  # a typedef
        else case
          when c_type.array? then [self.param_type(c_type.array_type), '*', c_type.array_size].join(' ')
          else self.param_type(c_type)
        end
      end
    end

    ##
    # @param  [Symbol, FFIDB::Type] c_type
    # @return [String]
    def param_type(c_type)
      case type = super(c_type)
        when Symbol then type.to_s  # a typedef
        when 'None' then type
        else "ctypes.#{type}"
      end
    end
  end # Python
end # FFIDB::Exporters
