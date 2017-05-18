module Joyent
  module Cloud
    module Pricing
      module Helpers

        def monthly_from_hourly(price)
          price * HOURS_PER_MONTH
        end

        # Returns string formatted with commas in the middle, such as "9,999,999"
        def currency_format(string)
          while string.sub!(/(\d+)(\d\d\d)/, '\1,\2');
          end
          string
        end
      end
    end
  end
end
