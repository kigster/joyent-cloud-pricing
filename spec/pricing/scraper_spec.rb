require 'pp'
require 'colored'
require 'spec_helper'

class OutdatedFixturesExpectation < RuntimeError; end
def check_if_fixtures_are_outdated config, flavor
  if !@config.nil? && !@config.empty? && @config[flavor].nil?
    STDERR.puts "Fixtures may be outdated... Cannot find flavor #{flavor} in the scraped config\n".red +
      "\t" + @config.keys.join("\n\t").yellow + "\n".white
    raise OutdatedFixturesExpectation.new("Fixtures are outdatd, missing flavor #{flavor} in the hash of #{config.keys.size} flavors.")
  end
end

RSpec.describe 'Joyent::Cloud::Pricing::Scraper' do
  let(:scraper) { Joyent::Cloud::Pricing::Scraper.new }

  let(:prices) { {'t4-standard-64G' => 1.68,
                  'g3-highcpu-1.75-smartos' =>0.127,
                  'g3-highio-60.5-kvm' => 3.067
               } }

  let(:cpus) { {'t4-standard-64G' => 32.0,
                  'g3-highcpu-1.75-smartos' => 2.0,
                  'g3-highio-60.5-kvm' => 8.0
               } }


  before do
    @config = scraper.scrape
  end

  it 'should load pricing configuration hash from Joyent Website' do
    puts "Scraped #{@config.keys.size} flavors from URL [".white + "#{Joyent::Cloud::Pricing::JOYENT_URL}".yellow + "]".white
    prices.keys.each do |flavor|
      check_if_fixtures_are_outdated @config, flavor
      expect(@config[flavor][:cost]).to \
        eql(prices[flavor])
    end
    cpus.keys.each do |flavor|
      check_if_fixtures_are_outdated @config, flavor
      expect(@config[flavor][:cpus]).to \
        eql(cpus[flavor])
    end
  end
end
