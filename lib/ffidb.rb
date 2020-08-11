# This is free and unencumbered software released into the public domain.

##
# FFI DB Command-Line Interface (CLI).
module FFIDB; end

require_relative 'ffidb/version'

require_relative 'ffidb/enum'
require_relative 'ffidb/errors'
require_relative 'ffidb/exporter'
require_relative 'ffidb/exporters'
require_relative 'ffidb/function'
require_relative 'ffidb/glob'
require_relative 'ffidb/header'
require_relative 'ffidb/header_parser'
require_relative 'ffidb/library'
require_relative 'ffidb/library_parser'
require_relative 'ffidb/location'
require_relative 'ffidb/parameter'
require_relative 'ffidb/registry'
require_relative 'ffidb/release'
require_relative 'ffidb/struct'
require_relative 'ffidb/symbolic'
require_relative 'ffidb/symbol_table'
require_relative 'ffidb/sysexits'
require_relative 'ffidb/type'
require_relative 'ffidb/typedef'
require_relative 'ffidb/union'

module FFIDB
  HEADER = "This is free and unencumbered software released into the public domain.".freeze

  ##
  # @return [String]
  def self.header
    HEADER
  end
end # FFIDB
