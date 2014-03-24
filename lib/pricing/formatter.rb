require 'open-uri'
require 'nokogiri'

module Joyent::Cloud::Pricing
  class Formatter
    HOURS_PER_MONTH = 720

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def monthly_price_for_flavor(flavor_name)
      config[flavor_name] ? sprintf("$%.2f", monthly_price(flavor_name)) : ""
    end

    def monthly_price(flavor_name)
      (config[flavor_name] || 0) * HOURS_PER_MONTH
    end

    def monthly_formatted_price_for_flavor(flavor, width = 10)
      config[flavor] ? formatted_price_for_value(monthly_price(flavor), width) : ""
    end

    def formatted_price_for_value(value, width = 10)
      sprintf("%#{width}s", currency_format(sprintf("$%.2f", value)))
    end

    # Returns string formatted with commas in the middle, such as "9,999,999"
    def currency_format string
      while string.sub!(/(\d+)(\d\d\d)/, '\1,\2');
      end
      string
    end
  end
end
