# This is free and unencumbered software released into the public domain.

require_relative 'ffidb/errors'
require_relative 'ffidb/exporter'
require_relative 'ffidb/exporters'
require_relative 'ffidb/function'
require_relative 'ffidb/header'
require_relative 'ffidb/library'
require_relative 'ffidb/location'
require_relative 'ffidb/parameter'
require_relative 'ffidb/parser'
require_relative 'ffidb/registry'
require_relative 'ffidb/version'

module FFIDB
  HEADER = "This is free and unencumbered software released into the public domain.".freeze

  ##
  # @return [String]
  def self.header
    HEADER
  end
end # FFIDB
