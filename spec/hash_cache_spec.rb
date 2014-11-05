require 'spec_helper'
require 'hash_cache'

describe HashCache do
  let(:hc) { HashCache.new }

  describe "#initialize" do
    it "initializes the internal hash" do
      expect(hc.cache).to eq({})
    end
  end

  describe "#fetch" do
    context "the given block is not nil" do
      it "stores the result of the given block" do
        hc.fetch('foo') do
          2 + 2
        end

        expect(hc.cache['foo']).to eq(4)
      end
    end

    context "the given block is nil" do
      it "doesn't store the given block" do
        hc.fetch('foo') do
          nil
        end

        expect(hc.cache.has_key?('foo')).to eq(false)
      end
    end
  end
end
