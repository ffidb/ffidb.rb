# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Python programming language (using ctypes).
  #
  # @see https://docs.python.org/3/library/ctypes.html
  class Python < FFIDB::Exporter
    # @see https://docs.python.org/3/library/ctypes.html
    TYPE_MAP = {
      'void'               => :None,
      # standard signed-integer types:
      'char'               => :char,
      'short'              => :short,
      'int'                => :int,
      'long'               => :long,
      'long long'          => :longlong,
      # standard unsigned-integer types:
      'unsigned char'      => :ubyte,
      'unsigned short'     => :ushort,
      'unsigned int'       => :uint,
      'unsigned long'      => :ulong,
      'unsigned long long' => :ulonglong,
      # standard floating-point types:
      'float'              => :float,
      'double'             => :double,
      'long double'        => :longdouble,
      # standard character-sequence types:
      'char *'             => :char_p,
      'const char *'       => :char_p,
      # <stdarg.h>
      'va_list'            => :void_p,
      # <stdbool.h>
      '_Bool'              => :bool,
      # <stddef.h>
      'size_t'             => :size_t,
      'wchar_t'            => :wchar_t,
      # <stdint.h>
      'int8_t'             => :int8,
      'int16_t'            => :int16,
      'int32_t'            => :int32,
      'int64_t'            => :int64,
      'uint8_t'            => :uint8,
      'uint16_t'           => :uint16,
      'uint32_t'           => :uint32,
      'uint64_t'           => :uint64,
      'intptr_t'           => :void_p,
      'uintptr_t'          => :void_p,
      # <sys/types.h>
      'ssize_t'            => :ssize_t,
      'off_t'              => :size_t, # TODO: https://stackoverflow.com/q/43671524
      # all other types:
      nil                  => :void_p,
    }

    def begin
      puts "# #{FFIDB.header}" if self.header?
      puts if self.header?
      puts "import ctypes, ctypes.util"
    end

    def begin_library(library)
      @library = library
      puts
      print library.name, ' = ctypes.CDLL('
      puts
      self.dlopen_paths_for(library).each_with_index do |library_path, i|
        print '    '
        print 'or ' unless i.zero?
        print 'ctypes.util.find_library("', library_path, '")'
        puts
      end
      print '    or "', library.dlopen.first, '"' unless self.options[:library_path] # TODO
      puts unless self.options[:library_path]
      puts ")"
    end

    def export_typedef(typedef, **kwargs)
      # TODO
    end

    def export_enum(enum, **kwargs)
      # TODO
    end

    def export_struct(struct, **kwargs)
      puts
      puts "class #{struct.name}(Structure):"
      print ' '*4
      puts 'pass' # TODO
    end

    def export_function(function, **kwargs)
      parameters = function.parameters.each_value.map { |p| py_type(p.type) }
      puts
      puts <<~EOS.lines.map { |line| kwargs[:disabled] ? line.prepend('#') : line }.join
      #{function.name} = #{@library.name}.#{function.name}
      #{function.name}.restype = #{py_type(function.type)}
      #{function.name}.argtypes = [#{parameters.join(', ')}]
      EOS
    end

    protected

    ##
    # @param  [FFIDB::Type] c_type
    # @return [String]
    def py_type(c_type)
      case
        when c_type.enum? then 'ctypes.c_int'
        else case py_type = TYPE_MAP[c_type.to_s] || TYPE_MAP[nil]
          when :None then py_type.to_s
          else "ctypes.c_#{py_type}"
        end
      end
    end
  end # Python
end # FFIDB::Exporters
