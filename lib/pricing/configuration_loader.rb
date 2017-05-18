require 'yaml'
require 'pricing'

module Joyent
  module Cloud
    module Pricing
      class ConfigurationLoader
        attr_accessor :source

        def initialize(source)
          self.source = source
        end

        def configuration
          hash = if source =~ /^(https?|\/\/|ftp)/
                   from_url
                 elsif source =~ /.*\.ya?ml$/i
                   from_yaml
                 end

          Configuration.new(hash)
        end

        def from_yaml
          legacy_prices = ::YAML.load(::File.read(LEGACY_FILENAME)) rescue nil
          legacy_prices  ||= {}
          current_prices = ::YAML.load(::File.read(source))[:pricing]
          legacy_prices.merge(current_prices)
        end

        def from_url
          Joyent::Cloud::Pricing::Scraper.new.scrape(source)
        end
      end
    end
  end
end

