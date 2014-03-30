require 'open-uri'
require 'nokogiri'
require_relative 'helpers'

module Joyent
  module Cloud
    module Pricing
      class Formatter

        include Helpers

        attr_reader :config

        def initialize(config)
          @config = config
        end

        def monthly_price(flavor)
          monthly_from_hourly(config.cost(flavor) || 0)
        end

        def format_price(value, width = 0)
          value = 0 if value.nil?
          value > 0 ? sprintf("%#{width}s", currency_format(sprintf("$%.2f", value))) : " " * width
        end

        def format_monthly_price(flavor, width = 0)
          format_price(monthly_price(flavor), width)
        end
      end
    end
  end
end
