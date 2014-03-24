require "pricing/version"

module Joyent
  module Cloud
    module Pricing

      DEFAULT_FILENAME  = 'config/joyent_pricing.yml'
      JOYENT_URL        = 'http://www.joyent.com/products/compute-service/pricing'
      HOURS_PER_MONTH   = 720

    end
  end
end

require "pricing/configuration"
require "pricing/scraper"
require "pricing/formatter"
