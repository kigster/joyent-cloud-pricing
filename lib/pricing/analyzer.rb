require_relative 'commit'

module Joyent::Cloud::Pricing
  class Analyzer

    attr_accessor :commit, :zone_list

    def initialize(commit, flavors = [])
      @commit = commit
      @zone_list = count_dupes(flavors).symbolize_keys
    end

    # Zones that are not on commit
    def excess_zone_list
      h = {}
      zone_list.each_pair { |flavor, count| diff = count - quantity_for(flavor); h[flavor] = diff if diff > 0 }
      h
    end

    # Zones that are committed, but do not exist
    def over_provisioned_zone_list
      h = {}
      zone_list.each_pair { |flavor, count| diff = count - quantity_for(flavor); h[flavor] = -diff if diff < 0 }
      h
    end

    # Non-discounted full price
    def monthly_full_price
      monthly_full_price_for(zone_list)
    end

    # Excess zones cost this much
    def excess_monthly_price
      monthly_full_price_for(excess_zone_list)
    end

    # Monthly for all of the commits
    def commit_monthly_price
      commit.monthly_price
    end

    # Commits + excess non reserved zones
    def total_monthly_price
      excess_monthly_price + commit_monthly_price
    end


    private

    def monthly_full_price_for zones
      total_price_for zones do |flavor|
        pricing.monthly(flavor)
      end
    end

    def total_price_for zones, &block
      zones.keys.inject(0) do |sum, flavor|
        sum += zones[flavor] * yield(flavor); sum
      end.round(2)
    end

    def quantity_for flavor
      r = commit.reserve_for(flavor)
      r ? r.quantity : 0
    end


    def count_dupes(ary)
      h = Hash.new(0)
      ary.each { |v| h.store(v, h[v]+1) }
      h.symbolize_keys
    end

    def pricing
      Joyent::Cloud::Pricing::Configuration.instance
    end

  end
end

