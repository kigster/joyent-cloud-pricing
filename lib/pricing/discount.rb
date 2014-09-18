module Joyent::Cloud::Pricing
  class Discount
    def apply(amount)
      raise 'Abstract method'
    end

  end

  class PercentDiscount < Discount
    attr_accessor :value
    def initialize(value)
      @value = value
      raise 'Discount value must be between 0% and 100%' unless self.value <= 100 && self.value >= 0
    end

    def apply(amount)
      amount - 0.01 * value * amount
    end

    def to_s
      "#{value}%"
    end
  end

  class Discount
    CALCULATORS = { percent: PercentDiscount }
    def self.type(type_name, *args)
      calc     = CALCULATORS[type_name]
      raise   "Type #{type_name} is unknown!" unless calc.is_a?(Class)
      calc.new *args
    end
  end

end
