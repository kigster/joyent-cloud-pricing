require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Scraper' do
  context 'scraping from URL'
  let(:scraper) { Joyent::Cloud::Pricing::Scraper.new }

  let(:prices) { {'t4-standard-512M' => 0.013,
                  't4-standard-1G' => 0.226,
                  't4-standard-2G' => 0.253
               } }

  let(:cpus) { {'g3-highmemory-17.125-smartos' => 2.0,
                  'g3-highcpu-1.75-smartos' => 2.0,
                  'g3-highstorage-64-smartos' => 16.0
               } }

  before do
    @config = scraper.scrape
  end

  it 'should load pricing configuration hash from Joyent Website' do
    prices.keys.each do |flavor|
      expect(@config[flavor][:cost]).to eq(prices[flavor]), "cost is incorrect for #{flavor}"
    end
    cpus.keys.each do |flavor|
      expect(@config[flavor][:cpus]).to eq(cpus[flavor]), "# of CPUs is incorrect for #{flavor}"
    end
  end
end
