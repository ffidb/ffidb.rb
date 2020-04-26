# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Ruby programming language (using FFI).
  #
  # @see https://github.com/ffi/ffi/wiki
  class Ruby < FFIDB::Exporter
    def begin
      puts "# #{FFIDB.header}"
      puts
      puts "require 'ffi'"
    end

    def begin_library(library)
      @library = library
      puts
      puts <<~EOS
      module #{library.name.capitalize}
        extend FFI::Library
        ffi_lib ['#{library.soname}']
      EOS
      puts
    end

    def finish_library
      puts "end # #{@library.name.capitalize}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| rb_type(p.type).inspect }
      puts "  attach_function :#{function.name}, [#{parameters.join(', ')}], :#{rb_type(function.type)}"
    end

    protected

    ##
    # @param  [String] c_type
    # @return [Symbol]
    def rb_type(c_type)
      # See: https://github.com/ffi/ffi/wiki/Types
      case c_type
        when 'void' then :void
        when '_Bool' then :bool
        when 'float', 'double' then c_type.to_sym
        when 'char', 'short', 'int', 'long' then c_type.to_sym
        when 'long long' then :long_long
        when 'unsigned char' then :uchar
        when 'unsigned short' then :ushort
        when 'unsigned int' then :uint
        when 'unsigned long' then :ulong
        when 'unsigned long long' then :ulong_long
        when 'char *', 'const char *' then :string
        else :pointer # DEBUG: "<<<<#{c_type}>>>>"
      end
    end
  end # Ruby
end # FFIDB::Exporters
