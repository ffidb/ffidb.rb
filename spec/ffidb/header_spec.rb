# This is free and unencumbered software released into the public domain.

require_relative '../../lib/ffidb'

include FFIDB

RSpec.describe FFIDB::Header do
  it "is comparable based on the name" do
    a, b, c = Header.new(name: 'a.h'), Header.new(name: 'b.h'), Header.new(name: 'c.h')
    expect(a == a).to be true
    expect(a != b).to be true
    expect(a < b).to be true
    expect(b < c).to be true
    expect(a < c).to be true
    expect(a > b).to be false
    expect(b > c).to be false
    expect(a > c).to be false
  end
end
