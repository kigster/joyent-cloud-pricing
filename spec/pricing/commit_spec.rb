require 'spec_helper'

describe 'Joyent::Cloud::Pricing::Commit' do

  context 'when some reserve pricing is defined' do
    let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit.yml' }
    let(:config) { Joyent::Cloud::Pricing::Configuration.instance }

    let(:expected_commit) { {
        'g3-highcpu-32-smartos-cc'      => {prepay: 8000.0, monthly: 500.0, years: 1, quantity: 10},
        'g3-highmemory-17.125-smartos'  => {prepay: 800.0, monthly: 60.0, years: 1, quantity: 12},
        'g3-highio-60.5-smartos'        => {prepay: 1800.0, monthly: 600.0, years: 1, quantity: 5}
    } }

    it 'should correctly load commit from the file' do
      expected_commit.keys.each do |flavor|
        expect(expected_commit[flavor]).to eql(commit.reserve_for(flavor).to_hash)
      end
    end

    it '#monthly_price' do
      expect(commit.monthly_price).to eql(8720.0)
    end

    it 'should have different custom pricing' do
      expect(commit.reserves.keys.size).to eql(3)
      expect(config.config[:'some-instance'][:cost]).to eql(2.451)
    end
  end

  context 'when no reserve but custom pricing is available' do
    let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit_noreserve.yml' }
    let(:config) { Joyent::Cloud::Pricing::Configuration.instance }
    let(:custom_flavor) { :'some-fake-flavor-again' }
    it 'should load properly and add custom to config' do

      expect(commit.reserves).to be_empty
      expect(config.config[custom_flavor.to_sym][:cost]).to eql(5.1)
      config.config.delete(custom_flavor.to_sym)
    end
  end

end
