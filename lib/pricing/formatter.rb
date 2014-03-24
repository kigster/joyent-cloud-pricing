require 'open-uri'
require 'nokogiri'

module Joyent::Cloud::Pricing
  class Formatter

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def monthly_price(flavor)
      (config[flavor] || 0) * HOURS_PER_MONTH
    end

    def format_price(value, width = 0)
      value = 0 if value.nil?
      value > 0 ? sprintf("%#{width}s", currency_format(sprintf("$%.2f", value))) : " " * width
    end

    def format_monthly_price(flavor, width = 0)
      format_price(monthly_price(flavor), width)
    end

    # Returns string formatted with commas in the middle, such as "9,999,999"
    def currency_format string
      while string.sub!(/(\d+)(\d\d\d)/, '\1,\2');
      end
      string
    end
  end
end
