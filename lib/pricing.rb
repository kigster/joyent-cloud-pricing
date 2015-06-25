require 'pricing/version'
require 'pricing/symbolize_keys'

module Joyent
  module Cloud
    module Pricing

      PRICING_FILENAME  = File.expand_path('../../config/joyent_pricing.yml', __FILE__)
      LEGACY_FILENAME   = File.expand_path('../../config/joyent_pricing_unpublished.yml', __FILE__)
      COMMIT_FILENAME   = 'config/commit_pricing.yml'
      JOYENT_URL        = 'https://www.joyent.com/public-cloud/pricing'
      HOURS_PER_MONTH   = 720

    end
  end
end

require 'pricing/flavor'
require 'pricing/helpers'
require 'pricing/configuration'
require 'pricing/scraper'
require 'pricing/formatter'
require 'pricing/commit'
require 'pricing/analyzer'
require 'pricing/reporter'
require 'pricing/discount'
