require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Configuration' do
  expected_prices = {
      'g3-standard-48-smartos' => 1.536,
      'g3-standard-0.625-smartos' => 0.02,
      'g3-standard-30-kvm' => 0.960,
      'g3-standard-8-smartos' => 0.26,
      'g3-highcpu-8-smartos' => 0.58,
      'g3-standard-0.5-smartos' => 0.016
  }

  let(:config) {
    Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'
  }

  context '#from_yaml' do
    expected_prices.keys.each do |flavor|
      it "should load pricing for #{flavor}" do
        expect(config.cost(flavor)).to eql(expected_prices[flavor])
      end
    end
  end

  context '#instance' do
    it 'should be able to create new instance, but remember the last once' do
      c1 = Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'
      c2 = Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'

      expect(Joyent::Cloud::Pricing::Configuration.instance).to eql(c2)
      expect(Joyent::Cloud::Pricing::Configuration.instance).not_to eql(c1)
    end

    it 'should have instance set' do
      expect(Joyent::Cloud::Pricing::Configuration.instance).not_to be_nil
    end
  end

  context '#flavor' do
    it 'should properly instantiate Flavor instance from hash' do
      flavor = config.flavor 'g3-standard-48-smartos'
      expect(flavor.class).to eql(Joyent::Cloud::Pricing::Flavor)

      expect(flavor.ram).to eql(12.0)
      expect(flavor.cpus).to eql(16.0)
      expect(flavor.cost).to eql(1.536)
    end
  end
end
