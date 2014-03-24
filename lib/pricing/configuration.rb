require 'yaml'

module Joyent::Cloud::Pricing
  class Configuration
    class << self
      def from_yaml(filename = DEFAULT_FILENAME)
        new(YAML.load(File.read(filename))[:pricing])
      end

      def to_yaml(filename = DEFAULT_FILENAME)
        File.open(filename, 'w') do |f|
          YAML.dump({:date => Time.now.to_s,
                     :pricing => config, }, f)
        end
      end
    end

    # map of image names to prices
    attr_accessor :config

    def initialize(hash = {})
      @config = hash
    end

    def [] value
      self.config[value]
    end
  end
end

