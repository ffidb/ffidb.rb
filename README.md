FFI DB Command-Line Interface (CLI)
===================================

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![RubyGems gem version](https://img.shields.io/gem/v/ffidb.svg)](https://rubygems.org/gems/ffidb)

Installation
------------

The tool can be installed quickly and easily on any computer that has
[Ruby](https://www.ruby-lang.org/en/) available:

    $ gem install ffidb

After installation, download and initialize the FFI DB registry as follows:

    $ ffidb init

Your local FFI DB registry is located at the path `$HOME/.ffidb/`.

Features
--------

### Code generation

| ID      | Language    | typedefs | enums | structs | unions | functions |
| :------ | :---------- | :------- | :---- | :------ | :----- | :-------- |
| c       | C           |          | ✔     |  ✔      |        |  ✔        | 
| c++     | C++         |          | ✔     |  ✔      |        |  ✔        | 
| dart    | Dart        |          | ✔     |  ✔      |        |  ✔        | 
| go      | Go          |          | ✔     |  ✔      |        |  ✔        | 
| java    | Java        |          | ✔     |  ✔      |        |  ✔        | 
| lisp    | Common Lisp |          | ✔     |  ✔      |        |  ✔        | 
| python  | Python      |          | ✔     |  ✔      |        |  ✔        | 
| ruby    | Ruby        |          | ✔     |  ✔      |        |  ✔        | 

Examples (API)
--------------

### Loading the library

    require 'ffidb'

### Enumerating FFI functions

    FFIDB::Registry.open do |registry|
      registry.open_library(:zlib) do |library|
        library.each_function do |function|
          p function
        end
      end
    end

Reference (CLI)
---------------

    Commands:
      ffidb export LIBRARY|SYMBOL...  # Generate C/C++/Go/Java/Python/Ruby/etc code
      ffidb help [COMMAND]            # Describe available commands or one specific command
      ffidb init                      # Initialize the registry (at: ~/.ffidb)
      ffidb list [LIBRARY]            # List FFI libraries and symbols
      ffidb parse HEADER...           # Parse .h header files
      ffidb search PATTERN            # Search for FFI symbols using a glob pattern
      ffidb show SYMBOL               # Show FFI symbol information
      ffidb update                    # Fetch updates to the registry (at: ~/.ffidb)

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

### Initializing the Registry

    Usage:
      ffidb init

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Initializes the local FFIDB registry, a prerequisite for using FFIDB.

      Your local FFIDB registry is located at $HOME/.ffidb.

      This command is equivalent to:

        $ git clone --depth=1 https://github.com/ffidb/ffidb.git $HOME/.ffidb

### Updating the Registry

    Usage:
      ffidb update

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Updates the local FFIDB registry, pulling updates from GitHub.

      Your local FFIDB registry is located at $HOME/.ffidb.

      This command is equivalent to:

        $ cd $HOME/.ffidb && git pull

### Listing Libraries and Symbols

    Usage:
      ffidb list [LIBRARY]

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Lists libraries with their FFI symbols (such as functions).

      For example:

        $ ffidb list lua

### Searching Libraries and Symbols

    Usage:
      ffidb search PATTERN

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Searches for FFI symbols (for example, functions) using a glob pattern.

      For example:

        $ ffidb search sqlite3_*_blob

### Viewing Symbol Information

    Usage:
      ffidb show SYMBOL

    Options:
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Shows information about an FFI symbol (for example, a function).

      For example:

        $ ffidb show lua_callk

### Generating FFI Bindings

    Usage:
      ffidb export LIBRARY|SYMBOL...

    Options:
      -f, [--format=FORMAT]            # Specify the output FORMAT (for example: java)
      -L, [--library-path=DIRECTORY]   # Load all libraries from DIRECTORY
          [--exclude=PATTERN]          # Exclude symbols matching the glob PATTERN
          [--exclude-from=FILE]        # Read exclude patterns from FILE
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Generates code for a target language (e.g., C/C++/Java/Python/Ruby/etc).

      Currently supported target formats and programming languages:

        --format=c                     # C99
        --format=c++                   # C++11
        --format=dart                  # Dart & Flutter
        --format=go                    # Go (cgo)
        --format=java                  # Java (JNA)
        --format=json                  # JSON
        --format=lisp                  # Common Lisp (CFFI)
        --format=python                # Python (ctypes)
        --format=ruby                  # Ruby (FFI)
        --format=yaml                  # YAML

      For example:

        $ ffidb export lua -f=c        # Export Lua bindings as C code
        $ ffidb export lua -f=cpp      # Export Lua bindings as C++ code
        $ ffidb export lua -f=java     # Export Lua bindings as Java JNA code
        $ ffidb export lua -f=python   # Export Lua bindings as Python ctypes code
        $ ffidb export lua -f=ruby     # Export Lua bindings as Ruby FFI code

### Parsing C Header Files

    Usage:
      ffidb parse HEADER...

    Options:
      -C, [--config=FILE]              # Use a library.yaml configuration FILE
      -D, [--define=VAR[=VAL]]         # Define VAR as a preprocessor symbol
      -I, [--include=DIRECTORY]        # Add DIRECTORY to the headers search path
      -d, [--debug], [--no-debug]      # Enable debugging
      -v, [--verbose], [--no-verbose]  # Be verbose (print warnings)
      -q, [--quiet], [--no-quiet]      # Be quiet (silence non-fatal errors)

    Description:
      Parses .h header files, outputting YAML using the FFIDB schema.

      Note: parsing requires installation of the 'ffi-clang' library:

        $ gem install ffi-clang
