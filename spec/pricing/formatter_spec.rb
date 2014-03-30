require 'spec_helper'

describe' Joyent::Cloud::Pricing::Formatter' do

  let(:config) { Joyent::Cloud::Pricing::Configuration.new(
                 {'g3-standard-48-smartos' => {cost: 1.536},
                  'g3-standard-0.625-smartos' => {cost: 0.02},
                  'g3-standard-30-kvm' => {cost: 0.960} }) }

  let(:formatter) { Joyent::Cloud::Pricing::Formatter.new(config) }

  context '#format_monthly_price' do
    it 'should return properly formatted monthly price' do
      expect(formatter.format_monthly_price 'g3-standard-0.625-smartos').to eql('$14.40')
      expect(formatter.format_monthly_price 'g3-standard-30-kvm').to eql('$691.20')
    end
  end
  context '#monthly_formatted_price_for_flavor' do
    it 'should return properly formatted monthly price' do
      expect(formatter.format_monthly_price 'g3-standard-48-smartos', 10).to eql(' $1,105.92')
    end
    it 'should return blank when no match was found' do
      expect(formatter.format_monthly_price 'asdfkasdfasdlfkjasl;dkjf').to eql('')
    end
  end
  context '#format_price' do
    it 'should return properly formatted price' do
      expect(formatter.format_price 24566.34, 10).to eql('$24,566.34')
      expect(formatter.format_price 4566.34,  10).to eql(' $4,566.34')
    end
    it 'should return blank string of given width for 0 or nil' do
      expect(formatter.format_price 0, 10).to eql('          ')
      expect(formatter.format_price nil, 10).to eql('          ')
    end
  end
end
