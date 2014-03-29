require_relative 'commit'
require 'erb'
require 'colored'

module Joyent::Cloud::Pricing
  class Reporter

    attr_accessor :commit, :zones_in_use, :analyzer, :formatter

    def initialize(commit = COMMIT, zones_in_use = [])
      @commit = case commit
                  when String
                    Joyent::Cloud::Pricing::Commit.from_yaml(commit)
                  when Joyent::Cloud::Pricing::Commit
                    commit
                  when nil
                    Joyent::Cloud::Pricing::Commit.new
                  else
                    raise NotImplementedError, "Unknown type of commit passed: #{commit.inspect}"
                end

      @zones_in_use = zones_in_use
      @analyzer = Analyzer.new(@commit, @zones_in_use)
      @formatter = Formatter.new(pricing.config)
    end

    def render
      @r = self
      @f = formatter
      ERB.new(REPORT_ASCII).result(binding)
    end

    def reserve?
      commit.reserves.size > 0
    end

    def zones
      zones_in_use.size
    end

    def pricing
      Configuration.instance
    end

    def monthly_without_commit_discount
      analyzer.monthly_full_price_for(analyzer.zone_list)
    end

    def excess_zones
      zones = analyzer.excess_zone_list.each_pair.map{|flavor, count| [ flavor, count, pricing.monthly(flavor) * count ]}.sort{|x,y| y[2] <=> x[2]}
      zones
    end

    def excess_zone_list
      excess_zones.map do |tuple|
        flavor, count, monthly = tuple
        sprintf(" %2d x %-36s : %20s",
          count, flavor, formatter.format_price(monthly, 20).red)
      end.join("\n")
    end

    REPORT_ASCII = <<ASCII
SUMMARY:
  Total # of zones                         : <%= sprintf("%20d", @r.zones).blue %>
<% if @r.reserve? %>  Total # of reserved zones                : <%= sprintf("%20d", @r.commit.total_zones).green %>
  Total # of reserved but WASTED zones     : <%= sprintf("%20d", @r.analyzer.over_reserved_zone_list.size || 0).red %>
  Reserve Pricing Term/Duration (years)    : <%= sprintf("%20d", @r.commit.years || 0).green %>

ONE TIME:
  Reserve Pricing Upfront Payments         : <%= @f.format_price(@r.commit.upfront_price, 20).green %>
<% end %>
MONTHLY:
<% if @r.reserve? %>  Monthly Cost of Reserve Pricing Zones    : <%= @f.format_price(@r.commit.monthly_price, 20).green %>
<% end %>  On Demand Resources Cost                 : <%= @f.format_price(@r.analyzer.excess_monthly_price, 20).red %>
<% if @r.reserve? %>  Total Monthly (reserve + on demand)      : <%= @f.format_price(@r.analyzer.total_monthly_price, 20).blue %><% end %>

YEARLY TOTALS:
<% if @r.reserve? %>  With reserve discounts                   : <%= @f.format_price(@r.commit.yearly_price, 20).green %>
<% end %>  Without reserve discounts                : <%= @f.format_price(@r.monthly_without_commit_discount * 12, 20).red %>
<% if @r.reserve? %>  Savings %                                : <%= (sprintf "%19d", (100 * (@r.monthly_without_commit_discount * 12 - @r.commit.yearly_price) / (@r.monthly_without_commit_discount * 12))).green %>%<% end %>

UNRESERVED FLAVORS MONTHLY COST
<%= @r.excess_zone_list %>

ASCII

  end

end
