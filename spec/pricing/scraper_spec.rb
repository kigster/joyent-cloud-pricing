require 'colored2'
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

  let(:prices) { {'k4-highcpu-kvm-750M' => 0.0325,
                  'k4-fastdisk-kvm-63.75G' =>2.1313,
                  'g4-highram-110G' => 1.6625
               } }

  let(:cpus) { {'g4-highram-110G' => 16.0,
                  'g4-highcpu-64G' => 32.0,
                  'k4-highram-kvm-63.75G' => 8.0
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
