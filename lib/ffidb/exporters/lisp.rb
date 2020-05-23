# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Common Lisp programming language (using CFFI).
  #
  # @see https://common-lisp.net/project/cffi/
  class Lisp < FFIDB::Exporter
    TYPE_MAP = 'lisp.yaml'

    def finish
      puts self.render_template('lisp.erb')
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def struct_type(c_type)
      case
        when c_type.array? then [c_type.array_type.to_s.to_sym, :count, c_type.array_size].map(&:inspect).join(' ')
        else self.param_type(c_type)
      end
    end

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def param_type(c_type)
      ':' << super(c_type)
    end
  end # Lisp
end # FFIDB::Exporters
