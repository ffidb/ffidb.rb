# This is free and unencumbered software released into the public domain.

require_relative '../../lib/ffidb'

include FFIDB

RSpec.describe FFIDB::Type do
  describe "#const_qualified?" do
    it "returns true for const-qualified types" do
      expect(Type.for('const bool *')).to be_const_qualified
      expect(Type.for('const unsigned char *')).to be_const_qualified
      expect(Type.for('const struct sqlite3_value *')).to be_const_qualified
    end
  end

  describe "#atomic?" do
    it "returns true for the _Bool type" do
      expect(Type.for('_Bool')).to be_atomic
    end

    it "returns true for integer types" do
      expect(Type.for('int')).to be_atomic
    end

    it "returns true for floating-point types" do
      expect(Type.for('float')).to be_atomic
      expect(Type.for('double')).to be_atomic
      expect(Type.for('long double')).to be_atomic
    end

    it "returns true for pointer types" do
      expect(Type.for('void *')).to be_atomic
      expect(Type.for('struct lua_State *')).to be_atomic
    end
  end

  describe "#void?" do
    it "returns true for the void type" do
      expect(Type.for('void')).to be_void
    end

    it "returns false for void pointer types" do
      expect(Type.for('void *')).to_not be_void
    end

    it "returns false for other types" do
      expect(Type.for('int')).to_not be_void
    end
  end

  describe "#bool?" do
    it "returns true for the _Bool type" do
      expect(Type.for('_Bool')).to be_bool
    end

    it "returns false for other types" do
      expect(Type.for('void')).to_not be_bool
    end
  end

  describe "#enum?" do
    # TODO
  end

  describe "#integer?" do
    it "returns true for standard signed-integer types" do
      expect(Type.for('char')).to be_integer
      expect(Type.for('short')).to be_integer
      expect(Type.for('int')).to be_integer
      expect(Type.for('long')).to be_integer
      expect(Type.for('long long')).to be_integer
    end

    it "returns true for standard unsigned-integer types" do
      expect(Type.for('unsigned char')).to be_integer
      expect(Type.for('unsigned short')).to be_integer
      expect(Type.for('unsigned int')).to be_integer
      expect(Type.for('unsigned long')).to be_integer
      expect(Type.for('unsigned long long')).to be_integer
    end

    it "returns true for <stddef.h> types" do
      expect(Type.for('size_t')).to be_integer
      expect(Type.for('wchar_t')).to be_integer
    end

    it "returns true for <stdint.h> types" do
      expect(Type.for('int8_t')).to be_integer
      expect(Type.for('int16_t')).to be_integer
      expect(Type.for('int32_t')).to be_integer
      expect(Type.for('int64_t')).to be_integer
      expect(Type.for('uint8_t')).to be_integer
      expect(Type.for('uint16_t')).to be_integer
      expect(Type.for('uint32_t')).to be_integer
      expect(Type.for('uint64_t')).to be_integer
    end

    it "returns true for <sys/types.h> types" do
      expect(Type.for('ssize_t')).to be_integer
      expect(Type.for('off_t')).to be_integer
    end

    it "returns false for other types" do
      expect(Type.for('void')).to_not be_integer
      expect(Type.for('_Bool')).to_not be_integer
      expect(Type.for('intptr_t')).to_not be_integer
      expect(Type.for('uintptr_t')).to_not be_integer
    end
  end

  describe "#signed_integer?" do
    it "returns true for standard signed-integer types" do
      expect(Type.for('char')).to be_signed_integer
      expect(Type.for('short')).to be_signed_integer
      expect(Type.for('int')).to be_signed_integer
      expect(Type.for('long')).to be_signed_integer
      expect(Type.for('long long')).to be_signed_integer
    end

    it "returns true for signed <stdint.h> types" do
      expect(Type.for('int8_t')).to be_signed_integer
      expect(Type.for('int16_t')).to be_signed_integer
      expect(Type.for('int32_t')).to be_signed_integer
      expect(Type.for('int64_t')).to be_signed_integer
    end

    it "returns true for signed <sys/types.h> types" do
      expect(Type.for('ssize_t')).to be_signed_integer
    end

    it "returns false for other types" do
      # standard unsigned-integer types:
      expect(Type.for('unsigned char')).to_not be_signed_integer
      expect(Type.for('unsigned short')).to_not be_signed_integer
      expect(Type.for('unsigned int')).to_not be_signed_integer
      expect(Type.for('unsigned long')).to_not be_signed_integer
      expect(Type.for('unsigned long long')).to_not be_signed_integer
      # <stddef.h>
      expect(Type.for('size_t')).to_not be_signed_integer
      # <stdint.h>
      expect(Type.for('uint8_t')).to_not be_signed_integer
      expect(Type.for('uint16_t')).to_not be_signed_integer
      expect(Type.for('uint32_t')).to_not be_signed_integer
      expect(Type.for('uint64_t')).to_not be_signed_integer
      # <sys/types.h>
      expect(Type.for('off_t')).to_not be_signed_integer
    end

    it "returns nil for ambiguous types" do
      # <stddef.h>
      expect(Type.for('wchar_t')).to_not be_signed_integer
    end
  end

  describe "#unsigned_integer?" do
    it "returns true for standard unsigned-integer types" do
      expect(Type.for('unsigned char')).to be_unsigned_integer
      expect(Type.for('unsigned short')).to be_unsigned_integer
      expect(Type.for('unsigned int')).to be_unsigned_integer
      expect(Type.for('unsigned long')).to be_unsigned_integer
      expect(Type.for('unsigned long long')).to be_unsigned_integer
    end

    it "returns true for unsigned <stddef.h> types" do
      expect(Type.for('size_t')).to be_unsigned_integer
    end

    it "returns true for unsigned <stdint.h> types" do
      expect(Type.for('uint8_t')).to be_unsigned_integer
      expect(Type.for('uint16_t')).to be_unsigned_integer
      expect(Type.for('uint32_t')).to be_unsigned_integer
      expect(Type.for('uint64_t')).to be_unsigned_integer
    end

    it "returns true for unsigned <sys/types.h> types" do
      expect(Type.for('off_t')).to be_unsigned_integer
    end

    it "returns false for other types" do
      # standard signed-integer types:
      expect(Type.for('char')).to_not be_unsigned_integer
      expect(Type.for('short')).to_not be_unsigned_integer
      expect(Type.for('int')).to_not be_unsigned_integer
      expect(Type.for('long')).to_not be_unsigned_integer
      expect(Type.for('long long')).to_not be_unsigned_integer
      # <stdint.h>
      expect(Type.for('int8_t')).to_not be_unsigned_integer
      expect(Type.for('int16_t')).to_not be_unsigned_integer
      expect(Type.for('int32_t')).to_not be_unsigned_integer
      expect(Type.for('int64_t')).to_not be_unsigned_integer
      # <sys/types.h>
      expect(Type.for('ssize_t')).to_not be_unsigned_integer
    end

    it "returns nil for ambiguous types" do
      # <stddef.h>
      expect(Type.for('wchar_t')).to_not be_unsigned_integer
    end
  end

  describe "#floating_point?" do
    it "returns true for standard floating-point types" do
      expect(Type.for('float')).to be_floating_point
      expect(Type.for('double')).to be_floating_point
      expect(Type.for('long double')).to be_floating_point
    end

    it "returns false for other types" do
      expect(Type.for('void')).to_not be_floating_point
    end
  end

  describe "#array?" do
    it "returns true for array types" do
      expect(Type.for('char [64]')).to be_array
      expect(Type.for('uint8_t [4000]')).to be_array
    end

    it "returns false for other types" do
      # TODO
    end
  end

  describe "#array_type" do
    it "returns the array type for array types" do
      expect(Type.for('char [64]').array_type).to eq(Type.for('char'))
      expect(Type.for('uint8_t [4000]').array_type).to eq(Type.for('uint8_t'))
    end
  end

  describe "#array_size" do
    it "returns the array size for array types" do
      expect(Type.for('char [64]').array_size).to eq(64)
      expect(Type.for('uint8_t [4000]').array_size).to eq(4000)
    end
  end

  describe "#pointer?" do
    it "returns true for pointer types" do
      expect(Type.for('void *')).to be_pointer
      expect(Type.for('void **')).to be_pointer
      expect(Type.for('char *')).to be_pointer
      expect(Type.for('char **')).to be_pointer
      expect(Type.for('char ***')).to be_pointer
      expect(Type.for('struct lua_State *')).to be_pointer
      expect(Type.for('int (*)(struct lua_State *)')).to be_pointer
    end

    it "returns false for other types" do
      expect(Type.for('void')).to_not be_pointer
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
      expect(Type.for('struct lua_State *')).to be_struct_pointer
      expect(Type.for('struct sqlite3 **')).to be_struct_pointer
    end

    it "returns false for other types" do
      expect(Type.for('void')).to_not be_struct_pointer
      expect(Type.for('void *')).to_not be_struct_pointer
      expect(Type.for('int (*)(struct lua_State *)')).to_not be_struct_pointer
    end
  end

  describe "#function_pointer?" do
    it "returns true for function-pointer types" do
      expect(Type.for('int (*)(struct lua_State *)')).to be_function_pointer
    end

    it "returns false for other types" do
      expect(Type.for('void *')).to_not be_function_pointer
    end
  end

  describe "#sizeof" do
    # TODO
  end

  describe "#alignof" do
    # TODO
  end
end
