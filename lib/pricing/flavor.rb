module Joyent::Cloud::Pricing
  class Flavor
    attr_accessor :name, :os, :cost, :ram, :cpus, :disk
    def initialize(name, options = {})
      @name = name
      @os = options[:os]
      @cost = (options[:cost] == 'N/A') ? nil : options[:cost].to_f
      @cpus = options[:cpus].to_f
      @disk = options[:disk].to_i
      @ram = options[:ram].to_f
    end

    def to_h
      {
        name: name,
        os: os,
        cost: cost,
        cpus: cpus,
        disk: disk,
        ram: ram
      }
    end
  end
end
