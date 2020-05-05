# This is free and unencumbered software released into the public domain.

require_relative '../lib/ffidb'

include FFIDB

RSpec.describe FFIDB::Type do
  describe "#const_qualified?" do
    it "returns true for const-qualified types" do
      expect(Type.new('const bool *')).to be_const_qualified
      expect(Type.new('const unsigned char *')).to be_const_qualified
      expect(Type.new('const struct sqlite3_value *')).to be_const_qualified
    end
  end

  describe "#atomic?" do
    it "returns true for the _Bool type" do
      expect(Type.new('_Bool')).to be_atomic
    end

    it "returns true for integer types" do
      expect(Type.new('int')).to be_atomic
    end

    it "returns true for floating-point types" do
      expect(Type.new('float')).to be_atomic
      expect(Type.new('double')).to be_atomic
      expect(Type.new('long double')).to be_atomic
    end

    it "returns true for pointer types" do
      expect(Type.new('void *')).to be_atomic
      expect(Type.new('struct lua_State *')).to be_atomic
    end
  end

  describe "#void?" do
    it "returns true for the void type" do
      expect(Type.new('void')).to be_void
    end

    it "returns false for void pointer types" do
      expect(Type.new('void *')).to_not be_void
    end

    it "returns false for other types" do
      expect(Type.new('int')).to_not be_void
    end
  end

  describe "#bool?" do
    it "returns true for the _Bool type" do
      expect(Type.new('_Bool')).to be_bool
    end

    it "returns false for other types" do
      expect(Type.new('void')).to_not be_bool
    end
  end

  describe "#enum?" do
    # TODO
  end

  describe "#integer?" do
    it "returns true for standard signed-integer types" do
      expect(Type.new('char')).to be_integer
      expect(Type.new('short')).to be_integer
      expect(Type.new('int')).to be_integer
      expect(Type.new('long')).to be_integer
      expect(Type.new('long long')).to be_integer
    end

    it "returns true for standard unsigned-integer types" do
      expect(Type.new('unsigned char')).to be_integer
      expect(Type.new('unsigned short')).to be_integer
      expect(Type.new('unsigned int')).to be_integer
      expect(Type.new('unsigned long')).to be_integer
      expect(Type.new('unsigned long long')).to be_integer
    end

    it "returns true for <stddef.h> types" do
      expect(Type.new('size_t')).to be_integer
      expect(Type.new('wchar_t')).to be_integer
    end

    it "returns true for <stdint.h> types" do
      expect(Type.new('int8_t')).to be_integer
      expect(Type.new('int16_t')).to be_integer
      expect(Type.new('int32_t')).to be_integer
      expect(Type.new('int64_t')).to be_integer
      expect(Type.new('uint8_t')).to be_integer
      expect(Type.new('uint16_t')).to be_integer
      expect(Type.new('uint32_t')).to be_integer
      expect(Type.new('uint64_t')).to be_integer
    end

    it "returns true for <sys/types.h> types" do
      expect(Type.new('ssize_t')).to be_integer
      expect(Type.new('off_t')).to be_integer
    end

    it "returns false for other types" do
      expect(Type.new('void')).to_not be_integer
      expect(Type.new('_Bool')).to_not be_integer
      expect(Type.new('intptr_t')).to_not be_integer
      expect(Type.new('uintptr_t')).to_not be_integer
    end
  end

  describe "#signed_integer?" do
    it "returns true for standard signed-integer types" do
      expect(Type.new('char')).to be_signed_integer
      expect(Type.new('short')).to be_signed_integer
      expect(Type.new('int')).to be_signed_integer
      expect(Type.new('long')).to be_signed_integer
      expect(Type.new('long long')).to be_signed_integer
    end

    it "returns true for signed <stdint.h> types" do
      expect(Type.new('int8_t')).to be_signed_integer
      expect(Type.new('int16_t')).to be_signed_integer
      expect(Type.new('int32_t')).to be_signed_integer
      expect(Type.new('int64_t')).to be_signed_integer
    end

    it "returns true for signed <sys/types.h> types" do
      expect(Type.new('ssize_t')).to be_signed_integer
    end

    it "returns false for other types" do
      # standard unsigned-integer types:
      expect(Type.new('unsigned char')).to_not be_signed_integer
      expect(Type.new('unsigned short')).to_not be_signed_integer
      expect(Type.new('unsigned int')).to_not be_signed_integer
      expect(Type.new('unsigned long')).to_not be_signed_integer
      expect(Type.new('unsigned long long')).to_not be_signed_integer
      # <stddef.h>
      expect(Type.new('size_t')).to_not be_signed_integer
      # <stdint.h>
      expect(Type.new('uint8_t')).to_not be_signed_integer
      expect(Type.new('uint16_t')).to_not be_signed_integer
      expect(Type.new('uint32_t')).to_not be_signed_integer
      expect(Type.new('uint64_t')).to_not be_signed_integer
      # <sys/types.h>
      expect(Type.new('off_t')).to_not be_signed_integer
    end

    it "returns nil for ambiguous types" do
      # <stddef.h>
      expect(Type.new('wchar_t')).to_not be_signed_integer
    end
  end

  describe "#unsigned_integer?" do
    it "returns true for standard unsigned-integer types" do
      expect(Type.new('unsigned char')).to be_unsigned_integer
      expect(Type.new('unsigned short')).to be_unsigned_integer
      expect(Type.new('unsigned int')).to be_unsigned_integer
      expect(Type.new('unsigned long')).to be_unsigned_integer
      expect(Type.new('unsigned long long')).to be_unsigned_integer
    end

    it "returns true for unsigned <stddef.h> types" do
      expect(Type.new('size_t')).to be_unsigned_integer
    end

    it "returns true for unsigned <stdint.h> types" do
      expect(Type.new('uint8_t')).to be_unsigned_integer
      expect(Type.new('uint16_t')).to be_unsigned_integer
      expect(Type.new('uint32_t')).to be_unsigned_integer
      expect(Type.new('uint64_t')).to be_unsigned_integer
    end

    it "returns true for unsigned <sys/types.h> types" do
      expect(Type.new('off_t')).to be_unsigned_integer
    end

    it "returns false for other types" do
      # standard signed-integer types:
      expect(Type.new('char')).to_not be_unsigned_integer
      expect(Type.new('short')).to_not be_unsigned_integer
      expect(Type.new('int')).to_not be_unsigned_integer
      expect(Type.new('long')).to_not be_unsigned_integer
      expect(Type.new('long long')).to_not be_unsigned_integer
      # <stdint.h>
      expect(Type.new('int8_t')).to_not be_unsigned_integer
      expect(Type.new('int16_t')).to_not be_unsigned_integer
      expect(Type.new('int32_t')).to_not be_unsigned_integer
      expect(Type.new('int64_t')).to_not be_unsigned_integer
      # <sys/types.h>
      expect(Type.new('ssize_t')).to_not be_unsigned_integer
    end

    it "returns nil for ambiguous types" do
      # <stddef.h>
      expect(Type.new('wchar_t')).to_not be_unsigned_integer
    end
  end

  describe "#floating_point?" do
    it "returns true for standard floating-point types" do
      expect(Type.new('float')).to be_floating_point
      expect(Type.new('double')).to be_floating_point
      expect(Type.new('long double')).to be_floating_point
    end

    it "returns false for other types" do
      expect(Type.new('void')).to_not be_floating_point
    end
  end

  describe "#pointer?" do
    it "returns true for pointer types" do
      expect(Type.new('void *')).to be_pointer
      expect(Type.new('void **')).to be_pointer
      expect(Type.new('char *')).to be_pointer
      expect(Type.new('char **')).to be_pointer
      expect(Type.new('char ***')).to be_pointer
      expect(Type.new('struct lua_State *')).to be_pointer
      expect(Type.new('int (*)(struct lua_State *)')).to be_pointer
    end

    it "returns false for other types" do
      expect(Type.new('void')).to_not be_pointer
    end
  end

  describe "#array_pointer?" do
    it "returns true for array-pointer types" do
      # TODO
    end

    it "returns false for other types" do
      # TODO
    end
  end

  describe "#struct_pointer?" do
    it "returns true for struct-pointer types" do
      expect(Type.new('struct lua_State *')).to be_struct_pointer
      expect(Type.new('struct sqlite3 **')).to be_struct_pointer
    end

    it "returns false for other types" do
      expect(Type.new('void')).to_not be_struct_pointer
      expect(Type.new('void *')).to_not be_struct_pointer
      expect(Type.new('int (*)(struct lua_State *)')).to_not be_struct_pointer
    end
  end

  describe "#function_pointer?" do
    it "returns true for function-pointer types" do
      expect(Type.new('int (*)(struct lua_State *)')).to be_function_pointer
    end

    it "returns false for other types" do
      expect(Type.new('void *')).to_not be_function_pointer
    end
  end

  describe "#sizeof" do
    # TODO
  end

  describe "#alignof" do
    # TODO
  end
end
