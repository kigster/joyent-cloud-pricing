module Joyent
  module Cloud
    module Pricing
      class Flavor
        # cost is hourly
        attr_accessor :name, :cost, :ram, :cpus, :disk, :os, :opts

        def initialize(name:, cost:, disk:, cpus:, ram:, **opts)
          if name =~ /kvm/
            self.os = 'kvm'
          else
            self.os = 'smartos'
          end


          self.name = name
          self.cost = cost == 'N/A' ? nil : cost.to_f
          self.disk = disk.to_i
          self.cpus = cpus.to_f
          self.ram  = ram.to_f
          self.opts = opts
        end

        def cost_monthly
          (cost * 730).round(2)
        end

        def to_h
          {
            name:    name,
            os:      os,
            cost:    cost,
            cpus:    cpus,
            disk:    disk,
            ram:     ram,
            monthly: cost_monthly
          }.tap do |h|
            h.merge!(opts) if opts && !opts.empty?
          end
        end
      end
    end
  end
end
