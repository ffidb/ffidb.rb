# This is free and unencumbered software released into the public domain.

require_relative '../lib/ffidb'

include FFIDB

RSpec.describe FFIDB::Parameter do
  it "is comparable based on the name" do
    a, b, c = Parameter.new('a'), Parameter.new('b'), Parameter.new('c')
    expect(a == a).to be true
    expect(a != b).to be true
    expect(a < b).to be true
    expect(b < c).to be true
    expect(a < c).to be true
    expect(a > b).to be false
    expect(b > c).to be false
    expect(a > c).to be false
  end

  describe "#eql?" do
    a_int  = Parameter.new('a', 'int')
    a_long = Parameter.new('a', 'long')
    b_int  = Parameter.new('b', 'int')
    b_long = Parameter.new('b', 'long')

    it "returns true when all attributes are equal" do
      expect(a_int).to eql(a_int.dup)
      expect(a_long).to eql(a_long.dup)
      expect(b_int).to eql(b_int.dup)
      expect(b_long).to eql(b_long.dup)
    end

    it "returns false otherwise" do
      expect(a_int).to_not eql(a_long)
      expect(a_long).to_not eql(a_int)
      expect(b_int).to_not eql(a_int)
      expect(b_long).to_not eql(a_int)
    end
  end
end
