# This is free and unencumbered software released into the public domain.

module FFIDB
  class Location < Struct.new(:file, :line, keyword_init: true)
    ##
    # @return [String]
    def to_s
      "#{self.file}:#{self.line}"
    end
  end # Location
end # FFIDB
