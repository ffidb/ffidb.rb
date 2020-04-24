# This is free and unencumbered software released into the public domain.

module FFIDB
  class Location < Struct.new(:file, :line, keyword_init: true)
    ##
    # @param  [FFI::Clang::ExpansionLocation] location
    # @param. [String, #to_s] default_name
    # @return [Parameter]
    def self.parse_clang_location(location, base_directory: nil)
      return nil if location.nil?
      self.new(
        file: base_directory ? Pathname(location.file).relative_path_from(base_directory).to_s : location.file,
        line: location.line,
      )
    end
  end # Location
end # FFIDB
