# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Ruby programming language (using FFI).
  #
  # @see https://github.com/ffi/ffi/wiki
  class Ruby < FFIDB::Exporter
    TYPE_MAP = 'ruby.yaml'

    def finish
      puts self.render_template('ruby.erb')
    end

    protected

    ##
    # @param  [Symbol, FFIDB::Type] c_type
    # @return [String]
    def struct_type(c_type)
      case c_type
        when Symbol then c_type.to_s  # a typedef
        else case
          when c_type.array? then [self.param_type(c_type.array_type), c_type.array_size].inspect
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
        else ':' << type.to_s
      end
    end
  end # Ruby
end # FFIDB::Exporters
