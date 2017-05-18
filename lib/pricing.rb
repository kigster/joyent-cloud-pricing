require 'pricing/version'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'yaml'
require 'logger'

module Joyent
  module Cloud
    module Pricing

      @log  = Logger.new(STDERR).freeze
      @lock = Mutex.new
      class << self
        attr_reader :lock

        def log=(value)
          @log = value
        end

        def log(level, *args)
          @log.send(level, *args) if ENV['DEBUG']
        end


      end

      class << self
        attr_accessor :settings

        def load(filename = 'config/settings.yml', environment = :default)
          path = File.expand_path('../../' + filename, __FILE__)
          log(:info, 'loading settings from ' + path + ', which ' + (File.exist?(path) ? 'exists.' : 'does not exist.'))
          raise ArgumentError, "Can not load settings file from #{path} which does not exist." unless File.exist?(path)
          hash = ::YAML.load(File.read(path))
          Hashie::Extensions::SymbolizeKeys.symbolize_keys!(hash)
          self.settings = Hashie::Mash.new(hash[environment])
        end
      end

      self.load

      class << self
        def files(type)
          raise ArgumentError, "No such file type #{type}" unless settings.files.key?(type)
          File.expand_path('../../' + self.settings.files[type], __FILE__)
        end

        def hours_in_month
          self.settings.calculations.hours_in_month
        end

        def joyent_url
          settings.scraper.url
        end
      end

      PRICING_FILENAME = self.files(:current)
      LEGACY_FILENAME  = self.files(:legacy)
      COMMIT_FILENAME  = self.files(:commit)
      JOYENT_URL       = self.joyent_url
      HOURS_PER_MONTH  = 720
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
