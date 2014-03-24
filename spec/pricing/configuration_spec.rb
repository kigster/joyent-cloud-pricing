require 'spec_helper'

describe ' Joyent::Cloud::Pricing::Configuration' do
  let(:expected_prices) { {
      "g3-standard-48-smartos" => 1.536,
      "g3-standard-0.625-smartos" => 0.02,
      "g3-standard-30-kvm" => 0.960} }

  it "should load pricing configuration hash from YAML" do
    config = Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'
    expected_prices.keys.each do |flavor|
      expect(config[flavor]).to eql(expected_prices[flavor])
    end
  end

  context "#instance" do
    it "should be able to create new instance, but remember the last once" do
      c1 = Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'
      c2 = Joyent::Cloud::Pricing::Configuration.from_yaml 'spec/fixtures/pricing.yml'

      expect(Joyent::Cloud::Pricing::Configuration.instance).to eql(c2)
      expect(Joyent::Cloud::Pricing::Configuration.instance).not_to eql(c1)
    end

    it "should have instance set" do
      expect(Joyent::Cloud::Pricing::Configuration.instance).not_to be_nil
    end
  end
end
