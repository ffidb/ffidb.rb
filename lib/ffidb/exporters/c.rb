# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the C programming language.
  class C < FFIDB::Exporter
    SYMBOL_INDENT    = 0
    EXTERN_QUALIFIER = 'extern'

    def begin
      puts "// #{FFIDB.header}"
      puts
      puts "#include <stdarg.h>    // for va_list"
      puts "#include <stdbool.h>   // for _Bool"
      puts "#include <stddef.h>    // for size_t, wchar_t"
      puts "#include <stdint.h>    // for {,u}int*_t"
      puts "#include <sys/types.h> // for off_t, ssize_t"
    end

    def begin_library(library)
      puts
      puts "// #{library.name} API"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map do |p|
        p.type = p.type.gsub('const char *const[]', 'const char * const *') # FIXME
        if p.type.include?('(*)') # function pointer
          p.type.sub('(*)', "(*#{p.name})")
        else
          "#{p.type} #{p.name}"
        end
      end
      indent = self.class.const_get(:SYMBOL_INDENT)
      print ' ' * indent if indent && indent.nonzero?
      print self.class.const_get(:EXTERN_QUALIFIER), ' '
      if function.type.include?('(*)')
        print function.type.sub('(*)', "(*#{function.name}(#{parameters.join(', ')}))")
      else
        print function.type, ' ', function.name, '('
        parameters.each_with_index do |p, i|
          print ', ' if i.nonzero?
          print p
        end
        print ')'
      end
      puts ';'
    end
  end # C
end # FFIDB::Exporters
