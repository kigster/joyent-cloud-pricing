require 'yaml'
require_relative 'reserve'

module Joyent::Cloud::Pricing
  class Commit
    class << self
      def from_yaml(filename = COMMIT_FILENAME)
        hash = YAML.load(File.read(filename))
        new(hash['reserved'] || {}, hash['custom'])
      end
    end

    # map of image names to prices
    attr_accessor :reserves, :custom

    def initialize(hash = {}, custom = nil)
      @config = hash.symbolize_keys
      self.reserves = {}
      @config.each_pair do |flavor, config|
        self.reserves[flavor] = Reserve.new(flavor, config)
      end
      if custom
        Joyent::Cloud::Pricing::Configuration.instance.merge(custom)
      end
    end

    def reserve_for flavor
      reserves[flavor.to_sym]
    end

    def monthly_price
      sum_of &->(reserve) {reserve.monthly }
    end

    def upfront_price
      sum_of &->(reserve) {reserve.prepay}
    end

    def total_zones
      sum_of &->(reserve) {1}
    end

    def yearly_price
      upfront_price + 12 * monthly_price
    end

    def years
      reserves.empty? ? 0 : reserves.values.first.years
    end

    def flavor_counts
      zone_list = {}
      reserves.keys.each{|zone| zone_list[zone] = reserves[zone].quantity}
      zone_list
    end

    private

    def sum_of
      reserves.values.inject(0) do |sum, reserve|
        sum += (yield(reserve)) * reserve.quantity; sum
      end
    end

  end
end

