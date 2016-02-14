require_relative 'commit'

module Joyent::Cloud::Pricing
  class Analyzer

    attr_accessor :commit, :zone_counts

    def initialize(commit, flavors = [])
      @commit = commit
      @zone_counts = count_dupes(flavors).symbolize_keys
    end

    # Zones that are not on commit, i.e on demand
    def excess_zone_counts
      h = {}
      zone_counts.each_pair { |flavor, count| diff = count - quantity_for(flavor); h[flavor] = diff if diff > 0 }
      h
    end

    # Zones that are committed, but do not exist
    def over_reserved_zone_counts
      h = {}
      zone_counts.each_pair { |flavor, count| diff = count - quantity_for(flavor); h[flavor] = -diff if diff < 0 }
      h
    end

    # Zones with flavor that's not recognized, and therefore unknown
    def unknown_zone_counts
      h = {}
      zone_counts.each_pair { |flavor, count|  h[flavor] = count if pricing.flavor(flavor).nil? }
      h
    end

    def unknown_zone_total
      count_for_all(unknown_zone_counts) do |flavor|
        1
      end.to_i
    end

    def have_unknown_zones?
      unknown_zone_counts.size > 0
    end

    def have_excess_zones?
      excess_zone_counts.size > 0
    end

    def have_over_reserved_zones?
      over_reserved_zone_counts.size > 0
    end

    # Non-discounted full price
    def monthly_full_price
      monthly_full_price_for(zone_counts)
    end

    # Excess zones cost this much
    def monthly_overages_price
      monthly_full_price_for(excess_zone_counts)
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
      count_for_all zones do |flavor|
        (commit.discount.nil?) ? pricing.monthly(flavor) : commit.discount.apply(pricing.monthly(flavor))
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

    def cpus
      count_props(:cpus)
    end

    def ram
      count_props(:ram)
    end

    def disk
      count_props(:disk)
    end

    private

    def count_props(operation)
      results = [ zone_counts, excess_zone_counts, commit.flavor_counts ].map do |list|
        count_for_all list do |flavor|
          f = pricing.flavor(flavor)
          f.respond_to?(operation.to_sym) ? f.send(operation) : 0
        end
      end
      { total: results[0].round(2), unreserved: results[1].round(2), reserved: results[2].round(2) }
    end


    def count_for_all zones, &block
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
