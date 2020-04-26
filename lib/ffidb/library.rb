# This is free and unencumbered software released into the public domain.

require 'pathname'
require 'psych'

module FFIDB
  class Library
    attr_reader :name
    attr_reader :version
    attr_reader :path
    attr_reader :soname

    ##
    # @param [String, #to_s] name
    # @param [String, #to_s] version
    # @param [Pathname, #to_s] path
    def initialize(name, version, path)
      @name = name.to_s
      @version = (version || :stable).to_s
      @path = Pathname(path)
      @soname = 'z' # FIXME
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
                  ps[k] = Parameter.new(name: k, type: v)
                  ps
                end
                yield Function.new(
                  name: yaml[:name],
                  type: yaml[:result], # FIXME
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
