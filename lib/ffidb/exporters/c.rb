# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C programming language.
  class C < FFIDB::Exporter
    SYMBOL_INDENT    = 0
    EXTERN_QUALIFIER = 'extern'

    def finish
      puts self.render_template('c.erb')
    end

    def _export_function(function, **kwargs)
      parameters = function.parameters.each_value.map do |p|
        p_type = case
          when p.type.function_pointer?
            p.type.to_s.sub('(*)', "(*#{p.name})")
          when self.options[:parameter_names] == false
            p.type.to_s.gsub(' *', '*')
          else "#{p.type.to_s.gsub(' *', '*')} #{p.name}"
        end
        p_type.gsub('const char *const[]', 'const char* const*') # FIXME
      end
      print ' '*self.symbol_indent if self.symbol_indent.nonzero?
      print self.extern_qualifier, ' ' if self.extern_qualifier
      if function.type.function_pointer?
        print function.type.to_s.sub('(*)', "(*#{function.name}(#{parameters.join(', ')}))")
      else
        print function.type, ' ', function.name, '('
        parameters.each_with_index do |p, i|
          print ', ' if i.nonzero?
          print p
        end
        print ')'
      end
      puts (self.options[:semicolon] == false ? '' : ';')
    end

    protected

    def symbol_indent
      self.class.const_get(:SYMBOL_INDENT)
    end

    def extern_qualifier
      self.class.const_get(:EXTERN_QUALIFIER)
    end
  end # C
end # FFIDB::Exporters
