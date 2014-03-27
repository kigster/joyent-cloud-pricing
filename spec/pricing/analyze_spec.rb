require 'spec_helper'

describe 'Joyent::Cloud::Pricing::Analyze' do

  let(:flavors) { %w(
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
  ) }
  let(:commit)   { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit.yml' }
  let(:analyzer) { Joyent::Cloud::Pricing::Analyzer.new(commit, flavors) }

  # need to have pricing so that it reloads from real price TODO: fix this
  before do
    Joyent::Cloud::Pricing::Configuration.from_yaml
  end

  it '#initialize' do
    expect(analyzer.zone_list).to_not be_empty
    expect(analyzer.zone_list).to eql (
                                          {:"g3-highcpu-16-smartos" => 2,
                                           :"g3-highcpu-32-smartos-cc" => 12,
                                           :"g3-highcpu-7-smartos" => 2,
                                           :"g3-highio-60.5-smartos" => 4,
                                           :"g3-highmemory-17.125-smartos" => 12,
                                           :"g3-standard-30-smartos" => 1
                                          })
  end

  it '#monthly_full_price' do
    expect(analyzer.monthly_full_price).to eql(35496.0)
  end

  it '#excess_zone_list' do
    expect(analyzer.excess_zone_list).to eql(
                                              {:"g3-highcpu-16-smartos" => 2,
                                               :"g3-highcpu-32-smartos-cc" => 2,
                                               :"g3-highcpu-7-smartos" => 2,
                                               :"g3-standard-30-smartos" => 1
                                              })
  end

  it '#excess_monthly_price' do
    expect(analyzer.excess_monthly_price).to eql( 6432.48 )
  end

  it '#over_committed_zone_list' do
    expect(analyzer.over_committed_zone_list).to eql( {:"g3-highio-60.5-smartos" => 1 })
  end


end
