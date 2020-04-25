# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  class Python < FFIDB::Exporter
    def begin
      puts "# #{FFIDB.header}"
      puts
      puts "import ctypes, ctypes.util"
    end

    def begin_library(library)
      @library = library
      puts
      puts "#{library.name} = ctypes.CDLL(ctypes.util.find_library('#{library.soname}'))"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| py_type(p.type) }
      puts
      puts <<~EOS
      #{function.name} = #{@library.name}.#{function.name}
      #{function.name}.restype = #{py_type(function.type)}
      #{function.name}.argtypes = [#{parameters.join(', ')}]
      EOS
    end

    protected

    ##
    # @param  [String] c_type
    # @return [String]
    def py_type(c_type)
      # See: https://docs.python.org/3/library/ctypes.html
      py_type = case c_type
        when 'void' then nil # None
        when '_Bool' then :bool
        when 'float', 'double' then c_type.to_sym
        when 'char', 'short', 'int', 'long' then c_type.to_sym
        when 'long long' then :longlong
        when 'unsigned char' then :ubyte
        when 'unsigned short' then :ushort
        when 'unsigned int' then :uint
        when 'unsigned long' then :ulong
        when 'unsigned long long' then :ulonglong
        when 'char *', 'const char *' then :char_p
        else :void_p # DEBUG: "<<<<#{c_type}>>>>"
      end
      py_type ? "ctypes.c_#{py_type}" : 'None'
    end
  end # Python
end # FFIDB::Exporters
