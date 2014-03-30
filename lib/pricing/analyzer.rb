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
    def over_reserved_zone_list
      h = {}
      zone_list.each_pair { |flavor, count| diff = count - quantity_for(flavor); h[flavor] = -diff if diff < 0 }
      h
    end

    # Non-discounted full price
    def monthly_full_price
      monthly_full_price_for(zone_list)
    end

    # Excess zones cost this much
    def monthly_overages_price
      monthly_full_price_for(excess_zone_list)
    end

    # Monthly for all of the commits
    def monthly_commit_price
      commit.monthly_price
    end

    # Commits + excess non reserved zones
    def monthly_total_price
      monthly_overages_price + monthly_commit_price
    end

    def upfront
      commit.upfront
    end

    def monthly_full_price_for zones
      total_price_for zones do |flavor|
        pricing.monthly(flavor)
      end
    end

    def yearly_overages_price
      monthly_overages_price * 12
    end

    def yearly_full_price
      monthly_full_price * 12
    end

    def yearly_total
      yearly_overages_price + commit.yearly_price
    end

    def yearly_savings
      yearly_full_price - yearly_total
    end

    def yearly_savings_percent
      100 * (yearly_full_price - yearly_total) / yearly_full_price
    end

    private

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

