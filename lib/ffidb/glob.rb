# This is free and unencumbered software released into the public domain.

module FFIDB
  class Glob
    attr_reader :pattern
    attr_reader :compiled

    def initialize(pattern, ignore_case: nil, match_substring: nil)
      @pattern = pattern.to_s
      regexp_pattern = Regexp.escape(@pattern).gsub('\*', '.*').gsub('\?', '.')
      regexp_pattern = "^#{regexp_pattern}$" unless match_substring
      regexp_options = ignore_case ? Regexp::IGNORECASE : nil
      @compiled = Regexp.new(regexp_pattern, regexp_options)
    end

    ##
    # @return [String]
    def to_s
      self.pattern
    end

    ##
    # @return [Boolean]
    def ===(string)
      self.compiled === string
    end
  end # Glob
end # FFIDB
