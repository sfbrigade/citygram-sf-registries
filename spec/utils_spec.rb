require 'spec_helper'

describe Utils do
  describe ".titleize" do
    it "capitalizes the first letter of every word in the given string" do
      test_string = "1531 HYDE STREET"
      expect(Utils.titleize(test_string)).to eq("1531 Hyde Street")
    end
  end
end
