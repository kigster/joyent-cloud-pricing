require_relative 'commit'
require 'erb'
require 'colored'

module Joyent::Cloud::Pricing
  class Reporter

    attr_accessor :commit, :zones_in_use, :analyzer, :formatter, :print_zone_list

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
      @analyzer = Joyent::Cloud::Pricing::Analyzer.new(@commit, @zones_in_use)
      @formatter = Joyent::Cloud::Pricing::Formatter.new(pricing.config)
      @print_zone_list = true
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
      Joyent::Cloud::Pricing::Configuration.instance
    end

    def excess_zones
      zones = analyzer.excess_zone_counts.each_pair.map{|flavor, count| [ flavor, count, pricing.monthly(flavor) * count ]}.sort{|x,y| y[2] <=> x[2]}
      zones
    end

    def excess_zone_list
      excess_zones.map do |tuple|
        flavor, count, monthly = tuple
        sprintf(" %2d x %-36s   %20s",
          count, flavor, formatter.format_price(monthly, 20).yellow)
      end.join("\n")
    end

    def zone_props_to_string(prop_type, width, suffix = '', divide_by = 1)
      props = analyzer.send(prop_type)
      [ props[:reserved], props[:unreserved], props[:total] ].map do |value|
        sprintf("%#{width}d#{suffix}", value / divide_by)
      end
    end

    SEPARATOR = ('.' * 65).cyan
    PROPS_FORMAT= '%20d %20d %20d'
    REPORT_ASCII = <<ASCII

ZONE COUNTS:
  Total # of zones                           <%= sprintf("%20d", @r.zones).cyan %>
<%- if @r.reserve? -%>
  Total # of reserved zones                  <%= sprintf("%20d", @r.commit.total_zones).green %>
  Total # of reserved but absent zones       <%= value = sprintf("%20d", @r.analyzer.over_reserved_zone_counts.size || 0); value == "0" ? value.blue : value.red %>
<%- end -%>

  Resources in use:<%= sprintf('%14s %15s %15s', 'Reserved', 'On-Demand', 'Total') %>
           CPUs  <%= props = @r.zone_props_to_string(:cpus, 16); props[0].green + props[1].yellow + props[2].cyan %>
           RAM   <%= props = @r.zone_props_to_string(:ram,  15, 'G'); props[0].green + props[1].yellow + props[2].cyan %>
           DISK  <%= props = @r.zone_props_to_string(:disk, 15, 'T', 1024); props[0].green + props[1].yellow + props[2].cyan %>
<%= SEPARATOR %>

MONTHLY COSTS:
<%- if @r.print_zone_list -%>
  List of on-demand flavors by price <%= @r.reserve? ? "(in excess of reserve)" : "" %>
<%= @r.excess_zone_list %>
                                                      <%= "___________".yellow %>
<%- end -%>
  On demand monthly                          <%= @f.format_price(@r.analyzer.monthly_overages_price, 20).yellow %>
<%- if @r.reserve? -%>
  Zones under reserve pricing                <%= @f.format_price(@r.commit.monthly_price, 20).green %>
<%- end -%>
<%- if @r.reserve? -%>
                                                      <%= "___________".cyan %>
  Total                                      <%= @f.format_price(@r.analyzer.monthly_total_price, 20).cyan %>
<%- end -%>
<%= SEPARATOR %>

YEARLY COSTS:
<%- if @r.reserve? -%>
  On demand yearly                           <%= @f.format_price(@r.analyzer.yearly_overages_price, 20).yellow %>
  Commit prepay one time fee                 <%= @f.format_price(@r.commit.upfront_price, 20).green %>
  Reserve yearly                             <%= @f.format_price(@r.commit.yearly_price, 20).green %>
                                                      <%= "___________".cyan %>
  Total                                      <%= @f.format_price(@r.analyzer.yearly_total, 20).cyan %>
<%- else -%>
  On demand yearly                           <%= @f.format_price(@r.analyzer.yearly_full_price, 20).cyan %>
<%- end -%>
<%- if @r.reserve? -%>

YEARLY RESERVE SAVINGS:
  Savings due to reserved pricing            <%= @f.format_price(@r.analyzer.yearly_savings, 20).green %>
  Savings %                                  <%= sprintf("%19d", @r.analyzer.yearly_savings_percent).green + '%'.green %>
<%- end -%>
<%= SEPARATOR %>

ASCII

  end

end
