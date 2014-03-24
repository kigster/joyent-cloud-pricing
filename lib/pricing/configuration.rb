require 'yaml'
require_relative 'helpers'

module Joyent::Cloud::Pricing
  class Configuration
    @@lock = Mutex.new # just in case

    class << self
      def from_yaml(filename = PRICING_FILENAME)
        @@lock.synchronize do
          @last_instance = new(YAML.load(File.read(filename))[:pricing])
        end
        @last_instance
      end

      def instance(reload = false)
        @last_instance = from_yaml if reload || @last_instance.nil?
        @last_instance
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
      monthly_from_hourly self[flavor]
    end

    def save_yaml(filename = PRICING_FILENAME)
      File.open(filename, 'w') do |f|
        YAML.dump({:date => Time.now.to_s,
                   :pricing => config, }, f)
      end
    end

  end
end

