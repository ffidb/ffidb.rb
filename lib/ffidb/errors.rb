# This is free and unencumbered software released into the public domain.

module FFIDB
  ##
  # Error indicating that opening a registry directory requires a newer
  # version of FFIDB.rb than the current one.
  class RegistryVersionMismatch < StandardError; end

  class ParseError < StandardError; end

  class ParseWarning < StandardError; end
end # FFIDB
