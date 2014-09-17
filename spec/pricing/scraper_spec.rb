require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Scraper' do
  context 'scraping from URL'
  let(:scraper) { Joyent::Cloud::Pricing::Scraper.new }

  let(:prices) { {'g3-standard-48-smartos' => 1.536,
                  'g3-standard-0.625-smartos' => 0.02,
                  'g3-standard-30-kvm' => 0.960
               } }

  let(:cpus) { {'g3-standard-48-smartos' => 12.0,
                  'g3-standard-0.625-smartos' => 0.15,
                  'g3-standard-30-kvm' => 8.0
               } }

  before do
    @config = scraper.scrape
  end

  it 'should load pricing configuration hash from Joyent Website' do
    prices.keys.each do |flavor|
      expect(@config[flavor][:cost]).to eql(prices[flavor])
    end
    cpus.keys.each do |flavor|
      expect(@config[flavor][:cpus]).to eql(cpus[flavor])
    end
  end
end
