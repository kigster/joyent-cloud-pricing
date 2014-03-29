require 'yaml'
require_relative 'helpers'

module Joyent::Cloud::Pricing
  class Configuration
    @@lock = Mutex.new # just in case

    class << self
      def instance(reload = false)
        @last_instance = from_yaml if reload || @last_instance.nil?
        @last_instance
      end

      def from_yaml(filename = PRICING_FILENAME)
        legacy_prices = YAML.load(File.read(LEGACY_FILENAME)) rescue nil
        legacy_prices ||= {}
        current_prices = YAML.load(File.read(filename))[:pricing]
        set_instance(new(current_prices.merge(legacy_prices)))
      end

      def from_url(url = JOYENT_URL)
        set_instance(new(Joyent::Cloud::Pricing::Scraper.new.scrape(url)))
      end

      private
      def set_instance(config)
        @@lock.synchronize do
          @last_instance = config
        end
      end
    end

    include Helpers

    # map of image names to prices
    attr_accessor :config

    def initialize(hash = {})
      @config = hash.symbolize_keys
    end

    def [] flavor
      self.config[flavor.to_sym]
    end

    def monthly flavor
      f = self[flavor]
      if f.nil?
        STDERR.puts "WARNING: can't find flavor #{flavor}, assuming 0"
        0
      else
        monthly_from_hourly f
      end

    end

    def save_yaml(filename = PRICING_FILENAME)
      File.open(filename, 'w') do |f|
        YAML.dump({:date => Time.now.to_s,
                   :pricing => config, }, f)
      end
    end

  end
end

