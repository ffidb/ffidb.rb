# This is free and unencumbered software released into the public domain.

require_relative 'sysexits'

module FFIDB
  ##
  # Base class for FFIDB errors.
  class Error < StandardError
    EXIT_CODE = Sysexits::EX_SOFTWARE

    ##
    # @return [Integer]
    def exit_code
      self.class.const_get(:EXIT_CODE)
    end
  end

  ##
  # An error indicating that a problem with the registry.
  class RegistryError < Error
    EXIT_CODE = Sysexits::EX_CONFIG
  end

  ##
  # An error indicating that opening a registry directory requires a newer
  # version of FFIDB.rb than the current one.
  class RegistryVersionMismatch < RegistryError; end

  ##
  # An error indicating that an FFI symbol was not found.
  class SymbolNotFound < Error
    EXIT_CODE = Sysexits::EX_NOINPUT

    def initialize(symbol_kind, symbol_name)
      super("#{symbol_kind.to_s.capitalize} not found: #{symbol_name}")
    end
  end

  ##
  # An error indicating that an FFI function was not found.
  class FunctionNotFound < SymbolNotFound
    def initialize(function_name)
      super(:function, function_name)
    end
  end

  ##
  # A warning raised during header file parsing.
  class ParseWarning < Error
    EXIT_CODE = Sysexits::EX_DATAERR
  end

  ##
  # An error raised during header file parsing.
  class ParseError < Error
    EXIT_CODE = Sysexits::EX_DATAERR
  end

  ##
  # A fatal error raised during header file parsing.
  class ParsePanic < Error
    EXIT_CODE = Sysexits::EX_DATAERR
  end
end # FFIDB
