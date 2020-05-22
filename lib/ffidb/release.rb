# This is free and unencumbered software released into the public domain.

module FFIDB
  class Release < ::Struct.new(:version, :headers)
    ##
    # @yield  [header]
    # @yieldparam [header] Header
    # @return [Enumerator]
    def each_header(&block)
      return self.to_enum(:each_header) unless block_given?
      self.headers(&block) if self.headers
    end
  end # Release
end # FFIDB
