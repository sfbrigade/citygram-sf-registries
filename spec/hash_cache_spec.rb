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
    it "stores the result of the given block" do
      hc.fetch('foo') do
        2 + 2
      end

      expect(hc.cache['foo']).to eq(4)
    end
  end
end
