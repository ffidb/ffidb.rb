# This is free and unencumbered software released into the public domain.

module FFIDB
  class Location < Struct.new(:file, :line, keyword_init: true)
  end # Location
end # FFIDB
