require 'spec_helper'

describe 'Joyent::Cloud::Pricing::Scraper' do
  context "scraping from URL"
  let(:config) { Joyent::Cloud::Pricing::Scraper.from_uri }

  let(:prices) { {"g3-standard-48-smartos" => 1.536,
                  "g3-standard-0.625-smartos" => 0.02,
                  "g3-standard-30-kvm" => 0.960} }

  it "should load pricing configuration hash from Joyent Website" do
    prices.keys.each do |flavor|
      expect(config[flavor]).to eql(prices[flavor])
    end
  end
end
