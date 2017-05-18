require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Reserve' do
  let(:pricing) { Joyent::Cloud::Pricing::Configuration.default }
  let(:flavor)  {'g3-highcpu-32-smartos-cc'}
  let(:reserve) {
    Joyent::Cloud::Pricing::Reserve.new(
        flavor, prepay: 8000.0, monthly: 500, quantity: 10, years: 1)
  }

  it 'should set members correctly' do
    expect(reserve.prepay).to eql(8000.0)
    expect(reserve.monthly).to eql(500.0)
  end

  it 'should calculate averaged monthly price' do
    expect(reserve.monthly_averaged).to eql(1166.67)
  end

  it 'should calculate total payout' do
    expect(reserve.total_payout).to eql((8000 + 12*500).round(2))
  end

  it 'should calculate monthly discount' do
    # important to call pricing to load it from real YAML,
    # not the fixtures
    expect(pricing.monthly flavor).to eq(1669.68)

    expect(reserve.monthly_discount).to eql(503.01)
    expect(reserve.monthly_discount_percent).to eql((100 * 503.01 / 1669.68).round(2))
  end

end
