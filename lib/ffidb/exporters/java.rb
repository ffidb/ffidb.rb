# This is free and unencumbered software released into the public domain.

require_relative '../exporter'

module FFIDB::Exporters
  ##
  # Code generator for the Java programming language (using JNA).
  #
  # @see https://github.com/java-native-access/jna/blob/master/www/GettingStarted.md
  class Java < FFIDB::Exporter
    def begin
      puts "// #{FFIDB.header}"
      puts
      puts <<~EOS
      import com.sun.jna.Library;
      import com.sun.jna.Native;
      import com.sun.jna.NativeLong;
      import com.sun.jna.Pointer;
      EOS
    end

    def begin_library(library)
      @interface = library.name.capitalize
      puts <<~EOS
      public interface #{@interface} extends Library {
        #{@interface} INSTANCE = (#{@interface})Native.load("#{library.soname}", #{@interface}.class);
      EOS
    end

    def finish_library
      puts "} // #{@interface}"
    end

    def export_function(function)
      parameters = function.parameters.each_value.map { |p| "#{jna_type(p.type)} #{p.name}" }
      puts
      puts "  #{jna_type(function.type)} #{function.name}(#{parameters.join(', ')});"
    end

    protected

    ##
    # @param  [String] c_type
    # @return [Symbol]
    def jna_type(c_type)
      # See: https://github.com/java-native-access/jna/blob/master/www/Mappings.md
      case c_type
        when 'void' then :void
        when '_Bool' then :boolean
        when 'float', 'double' then c_type.to_sym
        when 'char', 'unsigned char' then :byte
        when 'short', 'unsigned short' then :short
        when 'int', 'unsigned int' then :int
        when 'long', 'unsigned long' then :NativeLong
        when 'long long', 'unsigned long long' then :long
        when 'char *', 'const char *' then :String
        else :Pointer # DEBUG: "<<<<#{c_type}>>>>"
      end
    end
  end # Java
end # FFIDB::Exporters
