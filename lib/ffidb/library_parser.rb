# This is free and unencumbered software released into the public domain.

require_relative 'symbol_table'

require 'pathname'
require 'psych'

module FFIDB
  class LibraryParser
    include SymbolTable

    attr_reader :path

    ##
    # @param [Pathname, #to_s] path
    def initialize(path)
      @path = Pathname(path).freeze
    end

    ##
    # @yield  [typedef]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_typedef(&block)
      return self.to_enum(:each_typedef) unless block_given?
      self.parse_yaml_dir(self.path, [:typedef], &block)
    end

    ##
    # @yield  [enum]
    # @yieldparam [enum] Enum
    # @return [Enumerator]
    def each_enum(&block)
      return self.to_enum(:each_enum) unless block_given?
      self.parse_yaml_dir(self.path, [:enum], &block)
    end

    ##
    # @yield  [struct]
    # @yieldparam [struct] Struct
    # @return [Enumerator]
    def each_struct(&block)
      return self.to_enum(:each_struct) unless block_given?
      self.parse_yaml_dir(self.path, [:struct], &block)
    end

    ##
    # @yield  [union]
    # @yieldparam [union] Union
    # @return [Enumerator]
    def each_union(&block)
      return self.to_enum(:each_union) unless block_given?
      self.parse_yaml_dir(self.path, [:union], &block)
    end

    ##
    # @yield  [function]
    # @yieldparam [function] Function
    # @return [Enumerator]
    def each_function(&block)
      return self.to_enum(:each_function) unless block_given?
      self.parse_yaml_dir(self.path, [:function], &block)
    end

    ##
    # @yield  [symbol]
    # @yieldparam [symbol] Symbolic
    # @return [Enumerator]
    def each_symbol(&block)
      return self.to_enum(:each_symbol) unless block_given?
      self.parse_yaml_dir(self.path, nil, &block)
    end

    ##
    # @param  [Pathname] path
    # @param  [Array<Symbol>] kind_filter
    # @yield  [symbol]
    # @yieldparam [symbol] Symbolic
    # @return [void]
    def parse_yaml_dir(path, kind_filter = nil, &block)
      self.path.glob('*.yaml') do |path|
        path.open do |file|
          self.parse_yaml_file(file, kind_filter, &block)
        end
      end
    end

    ##
    # @param  [IO] file
    # @param  [Array<Symbol>] kind_filter
    # @yield  [symbol]
    # @yieldparam [symbol] Symbolic
    # @return [void]
    def parse_yaml_file(file, kind_filter = nil, &block)
      Psych.parse_stream(file) do |yaml_doc|
        kind = yaml_doc.children.first.tag[1..-1].to_sym
        next if kind_filter && !kind_filter.include?(kind)
        yaml = yaml_doc.to_ruby.transform_keys!(&:to_sym)
        case kind
          when :typedef
            yield Typedef.new(yaml[:name], Type.for(yaml[:type]), yaml[:comment])
          when :enum
            yield Enum.new(yaml[:name], yaml[:values] || {}, yaml[:comment])
          when :struct
            fields = (yaml[:fields] || {}).inject({}) do |fs, (k, v)|
              fs[k.to_sym] = Type.for(v)
              fs
            end
            yield Struct.new(yaml[:name], fields, yaml[:comment])
          when :union
            yield Union.new(yaml[:name], yaml[:fields] || {}, yaml[:comment])
          when :function
            parameters = (yaml[:parameters] || {}).inject({}) do |ps, (k, v)|
              k = k.to_sym
              ps[k] = Parameter.new(k, Type.for(v))
              ps
            end
            yield Function.new(
              name: yaml[:name],
              type: Type.for(yaml[:type]),
              parameters: parameters,
              definition: !yaml.has_key?(:definition) ? nil : Location.new(
                file: yaml.dig(:definition, 'file'),
                line: yaml.dig(:definition, 'line'),
              ),
              comment: yaml[:comment],
            )
        end
      end
    end
  end # LibraryParser
end # FFIDB
