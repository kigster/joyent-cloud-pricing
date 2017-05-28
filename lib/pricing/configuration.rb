require 'yaml'
require 'singleton'

require 'pricing'
require 'pricing/helpers'
require 'pricing/flavor'
require 'pricing/configuration_loader'

module Joyent
  module Cloud
    module Pricing

      class Configuration
        class << self
          attr_accessor :lock, :last_instance
          attr_writer :default

          def default
            @default ||= create(PRICING_FILENAME)
          end

          def create(source)
            ConfigurationLoader.new(source).configuration
          end
        end

        self.lock = Mutex.new

        include Helpers

        # map of image names to prices
        attr_accessor :config

        def initialize(hash = {})
          @config = Hashie::Extensions::SymbolizeKeys.symbolize_keys!(hash)
        end

        def cost(flavor)
          f = config[flavor.to_sym]
          f.nil? ? nil : f[:cost]
        end

        def flavor(flavor)
          f = config[flavor.to_sym]
          return nil if f.nil?
          Flavor.new(**f)
        end

        def monthly(flavor)
          f = self.cost(flavor)
          f.nil? ? 0 : monthly_from_hourly(f)
        end

        def save_yaml(filename = PRICING_FILENAME)
          File.open(filename, 'w') do |f|
            YAML.dump({ :date    => Time.now.to_s,
                        :pricing => config, }, f)
          end
        end

        def merge(additional_pricing)
          config.merge!(additional_pricing)
        end

        def ==(other)
          return false if other.class != self.class
          config.to_h == other.config.to_h
        end

      end
    end
  end
end

