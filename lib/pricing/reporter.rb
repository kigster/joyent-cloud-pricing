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
      ERB.new(REPORT_ASCII, 0, '-').result(binding)
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

    def excess_zones
      zones = analyzer.excess_zone_list.each_pair.map{|flavor, count| [ flavor, count, pricing.monthly(flavor) * count ]}.sort{|x,y| y[2] <=> x[2]}
      zones
    end

    def excess_zone_list
      excess_zones.map do |tuple|
        flavor, count, monthly = tuple
        sprintf(" %2d x %-36s   %20s",
          count, flavor, formatter.format_price(monthly, 20).yellow)
      end.join("\n")
    end

    SEPARATOR = ('.' * 65).cyan
    REPORT_ASCII = <<ASCII

ZONE COUNTS:
  Total # of zones                           <%= sprintf("%20d", @r.zones).cyan %>
<%- if @r.reserve? -%>
  Total # of reserved zones                  <%= sprintf("%20d", @r.commit.total_zones).green %>
  Total # of reserved but absent zones       <%= value = sprintf("%20d", @r.analyzer.over_reserved_zone_list.size || 0); value == "0" ? value.blue : value.red %>
  Reserve Pricing Term/Duration (years)      <%= sprintf("%20d", @r.commit.years || 0).blue %>
<%= SEPARATOR %>

RESERVE UPFRONT COST:
  Reserve Pricing Upfront Payments           <%= @f.format_price(@r.commit.upfront_price, 20).green %>
<%- end -%>
<%= SEPARATOR %>

MONTHLY COSTS:
  List of on-demand flavors by price
<%= @r.excess_zone_list %>
                                                      <%= "___________".yellow %>
  On Demand Monthly                          <%= @f.format_price(@r.analyzer.monthly_overages_price, 20).yellow %>

<%- if @r.reserve? -%>
  Zones Under Reserve Pricing                <%= @f.format_price(@r.commit.monthly_price, 20).green %>
<%- end -%>
<%- if @r.reserve? -%>
                                                      <%= "___________".cyan %>
  Total                                      <%= @f.format_price(@r.analyzer.monthly_total_price, 20).cyan %>
<%- end -%>
<%= SEPARATOR %>

YEARLY COSTS:
<%- if @r.reserve? -%>
  Savings due to Reserved Pricing            <%= @f.format_price(@r.analyzer.yearly_savings, 20).green %>
  Savings %                                  <%= sprintf("%19d", @r.analyzer.yearly_savings_percent).green + '%'.green %>

  Reserve Yearly                             <%= @f.format_price(@r.commit.yearly_price, 20).green %>
  On Demand Yearly                           <%= @f.format_price(@r.analyzer.yearly_overages_price, 20).yellow %>
                                                      <%= "___________".cyan %>
  Total                                      <%= @f.format_price(@r.analyzer.yearly_total, 20).cyan %>
<%- else -%>
  On Demand Yearly                           <%= @f.format_price(@r.analyzer.yearly_full_price, 20).cyan %>
<%- end -%>

ASCII

  end

end
