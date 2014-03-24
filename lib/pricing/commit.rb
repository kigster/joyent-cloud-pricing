require 'yaml'
require_relative 'reserve'

module Joyent::Cloud::Pricing
  class Commit
    class << self
      def from_yaml(filename = COMMIT_FILENAME)
        new(YAML.load(File.read(filename))['reserved'])
      end
    end

    # map of image names to prices
    attr_accessor :reserves

    def initialize(hash = {})
      @config = hash.symbolize_keys
      self.reserves = {}
      @config.each_pair do |flavor, config|
        self.reserves[flavor] = Reserve.new(flavor, config)
      end
    end

    def reserve_for flavor
      reserves[flavor.to_sym]
    end

  end
end

