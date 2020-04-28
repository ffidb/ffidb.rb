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

  describe "#public?" do
    it "returns true for functions with names that don't begin with underscores" do
      expect(Function.new(name: 'a')).to be_public
    end

    it "returns false for functions with names that do begin with underscores" do
      expect(Function.new(name: '_a')).to_not be_public
    end
  end

  describe "#nonpublic?" do
    it "returns true for functions with names that do begin with underscores" do
      expect(Function.new(name: '_a')).to be_nonpublic
    end

    it "returns false for functions with names that don't begin with underscores" do
      expect(Function.new(name: 'a')).to_not be_nonpublic
    end
  end

  describe "#nullary?" do
    it "returns true for 0-ary functions" do
      expect(Function.new(parameters: [])).to be_nullary
    end

    it "returns false for other functions" do
      expect(Function.new(parameters: [:a])).to_not be_nullary
    end
  end

  describe "#unary?" do
    it "returns true for 1-ary functions" do
      expect(Function.new(parameters: [:a])).to be_unary
    end

    it "returns false for other functions" do
      expect(Function.new(parameters: [])).to_not be_unary
    end
  end

  describe "#binary?" do
    it "returns true for 2-ary functions" do
      expect(Function.new(parameters: [:a, :b])).to be_binary
    end

    it "returns false for other functions" do
      expect(Function.new(parameters: [])).to_not be_binary
    end
  end

  describe "#ternary?" do
    it "returns true for 3-ary functions" do
      expect(Function.new(parameters: [:a, :b, :c])).to be_ternary
    end

    it "returns false for other functions" do
      expect(Function.new(parameters: [])).to_not be_ternary
    end
  end

  describe "#arity" do
    it "returns the number of parameters" do
      expect(Function.new(parameters: []).arity).to be_zero
      expect(Function.new(parameters: [:a]).arity).to be(1)
      expect(Function.new(parameters: [:a, :b]).arity).to be(2)
      expect(Function.new(parameters: [:a, :b, :c]).arity).to be(3)
    end
  end

  #describe "#result_type" do
  #  it "returns only the function's return type" do
  #    expect(Function.new(type: 'int (void)').result_type).to eq('int')
  #    expect(Function.new(type: 'const char *(void)').result_type).to eq('const char *')
  #  end
  #end
end
