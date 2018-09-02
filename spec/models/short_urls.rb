require 'rails_helper'

describe ShortUrl do 
  subject { described_class.new }
  describe "calculate_power" do
    it "check if power is calculation 62^0" do
      expect(subject.send(:calculate_power, 0)).to eq(1)
    end

    it "check if power is calculation 62^1" do
      expect(subject.send(:calculate_power, 1)).to eq(62)
    end

    it "check if power is calculation 62^2" do
      expect(subject.send(:calculate_power, 2)).to eq(3844)
    end

    it "check if power is calculation 62^100" do
      expect(subject.send(:calculate_power, 100)).to eq(173447861573683247714730657655312620453056954417135042074757049646310930624726299506063242973147383207308074513192299800436397892378848380276295319872954494152239940714065219813376)
    end
  end

  describe "decoder" do
    it "check if decoder computes correctly for '1'" do
      expect(subject.send(:decode, '1')).to eq(1)
    end

    it "check if decoder computes correctly for '1'" do
      expect(subject.send(:decode, 'Z')).to eq(61)
    end

    it "check if decoder computes correctly" do
      expect(subject.send(:decode, 'VcGNZ')).to eq(913196817)
    end
  end

  describe "encoder" do
    it "check if encoder computes correctly for '1'" do
      expect(subject.send(:encode, 1)).to eq('1')
    end

    it "check if encoder computes correctly for '1'" do
      expect(subject.send(:encode, 61)).to eq('Z')
    end

    it "check if encoder computes correctly" do
      expect(subject.send(:encode, 913196817)).to eq('VcGNZ')
    end
  end

  describe "add_scheme_if_not_present" do
    it "check 'www.google.com' add scheme" do
      expect(subject.send(:add_scheme_if_not_present, "www.google.com")).to eq('http://www.google.com')
    end

    it "check 'https://www.google.com' should not add scheme" do
      expect(subject.send(:add_scheme_if_not_present, "https://www.google.com")).to eq('https://www.google.com')
    end
  end
end