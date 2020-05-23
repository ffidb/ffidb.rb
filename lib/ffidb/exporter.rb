# This is free and unencumbered software released into the public domain.

#require 'erb'
require 'tilt' # https://rubygems.org/gems/tilt
require 'yaml'

module FFIDB
  class Exporter
    def self.for(format) # TODO
      require_relative 'exporters'
      case format&.to_sym
        when :c, :c99, :c11, :c18 then Exporters::C
        when :'c++', :'c++11', :'c++14', :'c++17', :'c++20', :cpp, :cxx then Exporters::Cpp
        when :csv then Exporters::CSV
        when :dart, :flutter then Exporters::Dart
        when :go, :cgo then Exporters::Go
        when :java, :jna then Exporters::Java
        when :json then Exporters::JSON
        when :lisp, :'common-lisp' then Exporters::Lisp
        when :python, :py then Exporters::Python
        when :ruby, :rb then Exporters::Ruby
        # TODO: csharp, haskell, julia, luajit, nim, nodejs, ocaml, php, racket, rust, zig
        when :yaml then Exporters::YAML
        else raise "unknown output format: #{format}"
      end
    end

    attr_reader :options

    def initialize(stream = $stdout, **kwargs)
      @stream = stream
      @options = kwargs.transform_keys(&:to_sym).freeze
    end

    def debug?
      self.options[:debug]
    end

    def verbose?
      self.options[:verbose] || self.debug?
    end

    def header?
      self.options[:header]
    end

    def emit(&block)
      begin
        self.begin
        yield self
        self.finish
      ensure
        self.close
      end
    end

    def dlopen_paths_for(library)
      if library_path = self.options[:library_path]
        library.objects.map { |lib| library_path.delete_suffix('/') << "/" << lib }
      else
        library.objects + library.dlopen
      end
    end

    def begin() end

    def begin_library(library)
      @library = library
      @libraries ||= []
      @libraries << library
      @typedefs ||= {}
      @enums ||= {}
      @structs ||= {}
      @unions ||= {}
      @functions ||= {}
    end

    def export_header(header)
      header.typedefs.sort.each { |typedef| self.export_typedef(typedef) }
      header.enums.sort.each { |enum| self.export_enum(enum) }
      header.structs.sort.each { |struct| self.export_struct(struct) }
      header.unions.sort.each { |union| self.export_union(union) }
      header.functions.sort.each { |function| self.export_function(function) }
    end

    def export_symbol(symbol, disabled: nil)
      self.__send__("export_#{symbol.kind}", symbol, disabled: disabled)
    end

    def export_typedef(typedef, disabled: nil)
      @typedefs[@library] ||= {}
      @typedefs[@library][typedef.name] = typedef
    end

    def export_enum(enum, disabled: nil)
      (@enums[@library] ||= []) << enum
    end

    def export_struct(struct, disabled: nil)
      (@structs[@library] ||= []) << self.resolve_struct(struct)
    end

    def export_union(union, disabled: nil)
      (@unions[@library] ||= []) << self.resolve_union(union)
    end

    def export_function(function, disabled: nil)
      (@functions[@library] ||= []) << self.resolve_function(function)
    end

    def finish_library
      @library = nil
    end

    def finish() end

    def close() end

    protected

    def puts(*args)
      @stream.puts *args
    end

    def print(*args)
      @stream.print *args
    end

    ##
    # @param  [String] comment
    # @param  [String] prefix
    # @return [String]
    def format_comment(comment, prefix)
      prefix = prefix + ' '
      comment.each_line.map(&:strip).map { |s| s.prepend(prefix) }.join("\n")
    end

    ##
    # @param  [Function] function
    # @feturn [Function]
    def resolve_function(function)
      function.type = self.resolve_type(function.type)
      function.parameters.transform_values! do |param|
        param.type = self.resolve_type(param.type)
        param
      end
      function
    end

    ##
    # @param  [Struct] struct
    # @feturn [Struct]
    def resolve_struct(struct)
      struct.fields.each do |field_name, field_type|
        struct.fields[field_name] = self.resolve_type(field_type)
      end
      struct
    end

    ##
    # @param  [Union] union
    # @feturn [Union]
    def resolve_union(union)
      self.resolve_struct(union)
    end

    ##
    # @param  [Type] type
    # @return [Type, Symbol]
    def resolve_type(type)
      case
        when type.struct_pointer?
          name = type.spec.gsub(/^const /, '').gsub(/^struct /, '').gsub(/\s*\*+$/, '')
          name.to_sym
        when type.struct? || type.union?
          type
        when typedef = lookup_typedef(type.name)
          case typedef.type.tag
            when :enum then type.name.to_sym
            when :struct then (type.pointer? ? type.name : "#{type.name}.by_value").to_sym # FIXME
            else typedef.type
          end
        else type
      end
    end

    ##
    # @param  [Type] type
    # @return [Symbolic]
    def lookup_symbol(type)
      self.lookup_typedef(type.name)
    end

    ##
    # @param  [Symbol] type_name
    # @return [Typedef]
    def lookup_typedef(type_name)
      @typedefs && @typedefs[@library] && @typedefs[@library][type_name]
    end

    ##
    # @param  [Symbol, Type] c_type
    # @return [#to_s]
    def struct_type(c_type)
      return c_type if c_type.is_a?(Symbol) # a resolved typedef
      self.param_type(c_type)
    end

    ##
    # @param  [Symbol, Type] c_type
    # @return [#to_s]
    def param_type(c_type)
      return c_type if c_type.is_a?(Symbol) # a resolved typedef
      case
        when type = typemap[c_type.to_s] then type
        when c_type.enum? then typemap['int']
        when c_type.pointer? then typemap['void *']
        when c_type.array? then typemap['void *']
        else
          warn "#{$0}: unknown C type #{c_type}, mapping to enum (int)" if debug?
          typemap['int'] # TODO: typedef or enum
      end
    end

    def typemap
      @typemap ||= self.load_typemap(self.class.const_get(:TYPE_MAP))
    end

    def load_typemap(typemap_name)
      ::YAML.load(File.read(self.path_to_typemap(typemap_name))).freeze
    end

    def path_to_typemap(typemap_name)
      File.expand_path("../../etc/mappings/#{typemap_name}", __dir__)
    end

    def render_template(template_name)
      #ERB.new(self.load_template(template_name)).result(binding)
      Tilt.new(self.path_to_template(template_name)).render(self)
    end

    def load_template(template_name)
      File.read(self.path_to_template(template_name)).freeze
    end

    def path_to_template(template_name)
      File.expand_path("../../etc/templates/#{template_name}", __dir__)
    end
  end # Exporter
end # FFIDB
