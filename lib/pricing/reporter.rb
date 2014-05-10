require_relative 'commit'
require 'erb'
require 'colored'

module Joyent::Cloud::Pricing
  class Reporter

    attr_accessor :commit, :zones_in_use, :analyzer, :formatter, :print_zone_list, :template

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
      @template = File.read(File.expand_path('../report.txt.erb', __FILE__))
    end

    def render(options = {})
      disable_color if (options && options[:disable_color]) || ENV['NO_COLOR']
      @r = self
      ERB.new(template, 0, '-').result(binding)
    end

    def pricing
      Joyent::Cloud::Pricing::Configuration.instance
    end

    # Various formatting helpers follow below
    # Note that we delegate to analyzer for majority of calls.
    # Sorry about that method_missing :(

    def method_missing(method, *args, &block)
      if @analyzer.respond_to?(method)
        @analyzer.send(method, *args, &block)
      else
        super
      end
    end

    def format_price *args
      @formatter.format_price *args
    end

    def have_commit_pricing?
      commit.reserves.size > 0
    end

    def excess_zones_for_print
      zones_for_print(zone_counts_to_list(analyzer.excess_zone_counts), :yellow)
    end

    def over_reserved_zones_for_print
      zones_for_print(analyzer.over_reserved_zone_counts)
    end

    def unknown_zones_for_print
      zone_list_for_print(analyzer.unknown_zone_counts.keys)
    end

    def zones_for_print(zone_list, color = nil)
      zone_list.map do |tuple|
        flavor, count, monthly = tuple
        price = formatter.format_price(monthly, 16)
        price = price.send(color) if color
        sprintf("     %2d x %-36s   %16s", count, flavor, price)
      end.join("\n")
    end

    def zone_list_for_print(list, format = '    %-40s')
      list.map { |k| sprintf(format, k) }.join("\n")
    end

    def zone_counts_to_list zone_count_hash
      zones = zone_count_hash.each_pair.
          map { |flavor, count| [flavor, count, pricing.monthly(flavor) * count] }.
          sort { |x, y| y[2] <=> x[2] }
      zones
    end

    def zone_props_to_string(prop_type, width, suffix = '', divide_by = 1)
      props = analyzer.send(prop_type)
      [props[:reserved], props[:unreserved], props[:total]].map do |value|
        sprintf("%#{width}d#{suffix}", value / divide_by)
      end
    end

    private

    def disable_color
      String.instance_eval do
        %w(
          black
          red
          green
          yellow
          blue
          magenta
          cyan
          white
        ).each do |color|
            define_method(color) do
              self
            end
        end
      end
    end
  end
end
