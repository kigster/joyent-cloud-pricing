require 'pricing/helpers'

module Joyent
  module Cloud
    module Pricing
      class Reserve
        include Helpers

        attr_accessor :flavor, :monthly, :prepay, :years, :quantity

        def initialize(flavor, config)
          @flavor   = flavor.to_sym
          @prepay   = config[:prepay].to_f
          @monthly  = config[:monthly].to_f
          @quantity = config[:quantity].to_i
          @years    = config[:years]
        end

        def monthly_averaged
          (total_payout / (@years * 12)).round(2)
        end

        def total_payout
          (@prepay + @years * 12 * @monthly).round(2)
        end

        def total_discount
          (monthly_full_price * 12 * years).round(2) - total_payout
        end

        def monthly_discount
          (total_discount / 12 / years).round(2)
        end

        def monthly_discount_percent
          (100 * monthly_discount / monthly_full_price).round(2)
        end

        def monthly_full_price
          pricing.monthly flavor
        end

        def to_hash
          { prepay: prepay, monthly: monthly, years: years, quantity: quantity }
        end

        private

        def pricing
          Joyent::Cloud::Pricing::Configuration.default
        end

      end
    end
  end
end


