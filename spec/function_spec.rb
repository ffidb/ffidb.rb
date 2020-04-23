# This is free and unencumbered software released into the public domain.

require_relative '../lib/ffidb'

include FFIDB

RSpec.describe FFIDB::Function do
  it "is comparable based on the name" do
    a, b, c = Function.new(name: 'a'), Function.new(name: 'b'), Function.new(name: 'c')
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
