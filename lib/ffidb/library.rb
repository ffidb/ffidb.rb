# This is free and unencumbered software released into the public domain.

require 'pathname'
require 'psych'
require 'yaml'

module FFIDB
  class Library
    include Comparable

    attr_reader :name
    attr_reader :version
    attr_reader :path
    attr_reader :summary
    attr_reader :website
    attr_reader :source
    attr_reader :packages
    attr_reader :dlopen
    attr_reader :objects
    attr_reader :headers

    ##
    # @param  [Library] other
    # @return [Integer]
    def <=>(other) self.name <=> other&.name end # FIXME

    ##
    # @param [String, #to_s] name
    # @param [String, #to_s] version
    # @param [Pathname, #to_s] path
    def initialize(name, version, path)
      @name, @version = name.to_s.freeze, (version || :stable).to_s.freeze
      @path = Pathname(path).freeze
      if (metadata_path = @path.join('library.yaml')).exist?
        metadata  = YAML.load(metadata_path.read).transform_keys(&:to_sym)
        metadata.delete(:name)
        @summary  = metadata.delete(:summary).freeze
        @website  = metadata.delete(:website).freeze
        @source   = metadata.delete(:source).freeze
        @packages = metadata.delete(:packages).transform_keys(&:to_sym).freeze
        dlopen    = metadata.delete(:dlopen).freeze
        @dlopen   = dlopen.is_a?(Array) ? dlopen : [dlopen]
        @objects  = (metadata.delete(:objects) || []).freeze
        @headers  = (metadata.delete(:headers) || []).freeze
      end
    end

    ##
    # @return [String]
    def soname() self.objects&.first end

    ##
    # @return [Array<String>]
    def types
      self.each_type.to_a
    end

    ##
    # @yield  [type_name]
    # @return [Enumerator]
    def each_type(&block)
      return self.to_enum(:each_type) unless block_given?
      types = {}
      self.each_function do |function|
        types[function.type] ||= true
        function.parameters.each_value do |parameter|
          types[parameter.type] ||= true
        end
      end
      types.keys.sort.each(&block)
    end

    ##
    # @yield  [function]
    # @return [Enumerator]
    def each_function(&block)
      return self.to_enum(:each_function) unless block_given?
      self.path.join(self.version).glob('*.yaml') do |path|
        path.open do |file|
          Psych.parse_stream(file) do |yaml_doc|
            case yaml_doc.children.first.tag.to_sym
              when :'!function'
                yaml = yaml_doc.to_ruby.transform_keys!(&:to_sym)
                parameters = (yaml[:parameters] || {}).inject({}) do |ps, (k, v)|
                  k = k.to_sym
                  ps[k] = Parameter.new(k, Type.new(v))
                  ps
                end
                yield Function.new(
                  name: yaml[:name],
                  type: Type.new(yaml[:type]),
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
      end
    end
  end # Library
end # FFIDB
