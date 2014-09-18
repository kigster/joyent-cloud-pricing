require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Analyzer' do

  FLAVORS =  %w(
      g3-highcpu-16-smartos
      g3-highcpu-16-smartos
      g3-standard-30-smartos
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-32-smartos-cc
      g3-highcpu-7-smartos
      g3-highcpu-7-smartos
      g3-highio-60.5-smartos
      g3-highio-60.5-smartos
      g3-highio-60.5-smartos
      g3-highio-60.5-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      g3-highmemory-17.125-smartos
      some-unknown-flavor
      some-other-unknown-flavor
      some-other-unknown-flavor
    )

  let(:flavors) { FLAVORS }
  let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit.yml' }
  let(:analyzer) { Joyent::Cloud::Pricing::Analyzer.new(commit, flavors) }

  # need to have pricing so that it reloads from real price TODO: fix this
  before do
    Joyent::Cloud::Pricing::Configuration.from_yaml
  end

  it '#initialize' do
    expect(analyzer.zone_counts).to_not be_empty
    expect(analyzer.zone_counts).to eql (
                                            {:'g3-highcpu-16-smartos' => 2,
                                             :'g3-highcpu-32-smartos-cc' => 12,
                                             :'g3-highcpu-7-smartos' => 2,
                                             :'g3-highio-60.5-smartos' => 4,
                                             :'g3-highmemory-17.125-smartos' => 12,
                                             :'g3-standard-30-smartos' => 1,
                                             :'some-unknown-flavor' => 1,
                                             :'some-other-unknown-flavor' => 2
                                            })
  end

  context 'monthly prices' do
    it '#monthly_full_price' do
      expect(analyzer.monthly_full_price).to eql(35496.0)
    end

    it '#monthly_overages_price' do
      expect(analyzer.monthly_overages_price).to eql(6432.48)
    end
  end

  context 'zone frequency counts' do
    it '#excess_zone_counts' do
      expect(analyzer.excess_zone_counts).to eql(
                                                 {:'g3-highcpu-16-smartos' => 2,
                                                  :'g3-highcpu-32-smartos-cc' => 2,
                                                  :'g3-highcpu-7-smartos' => 2,
                                                  :'g3-standard-30-smartos' => 1,
                                                  :'some-unknown-flavor' => 1,
                                                  :'some-other-unknown-flavor' => 2
                                                 })
    end

    it '#over_reserved_zone_counts' do
      expect(analyzer.over_reserved_zone_counts).to eql({:'g3-highio-60.5-smartos' => 1})
    end
  end

  context 'reserved and unreserved totals for flavor properties' do
    it '#cpus' do
      expect(analyzer.cpus).to eql({total: 494.0, reserved: 384.0, unreserved: 118.0})
    end

    it '#ram' do
      expect(analyzer.ram).to eql({total: 907.5, unreserved: 140.0, reserved: 828.0})
    end

    it '#disk' do
      expect(analyzer.disk).to eql({total: 28655.0, unreserved: 5807.0, reserved: 24300.0})
    end
  end

  context 'for unknown instances' do
    it 'should return some-unknown-flavor' do
      expect(analyzer.unknown_zone_counts).to eql({ :'some-unknown-flavor' => 1,
                                                    :'some-other-unknown-flavor' => 2 })
      expect(analyzer.unknown_zone_total).to eql(3)
    end
  end

  context 'for commit with discount' do
    let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit_with_discount.yml' }
    let(:discount) { 0.7 }

    context 'should apply discount only to on demand instances' do
      it '#monthly_full_price' do
        expect(analyzer.monthly_full_price).to be_within(0.01).of(35496.0 * discount)
      end

      it '#monthly_overages_price' do
        expect(analyzer.monthly_overages_price).to be_within(0.01).of(6432.48 * discount)
      end

    end

  end

end
