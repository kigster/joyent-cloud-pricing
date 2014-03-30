module Joyent::Cloud::Pricing
  class Flavor
    attr_accessor :name, :os, :cost, :ram, :cpus, :disk

    def initialize(name, os: os, cost: cost, ram: ram, cpus: cpus, disk: disk)
      @name = name
      @os = os
      @cost = (cost == 'N/A') ? nil : cost.to_f
      @cpus = cpus.to_f
      @disk = disk.to_i
      @ram = ram.to_f
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
