require 'spec_helper'

RSpec.describe 'Joyent::Cloud::Pricing::Discount' do
  let(:pricing) { Joyent::Cloud::Pricing::Configuration.default }
  let(:discount) { Joyent::Cloud::Pricing::Discount.type(:percent, 30)  }
  let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit_with_discount.yml' }

  it "should apply percent discount correctly" do
    expect(discount.apply(10)).to eql(7.0)
  end

  it "should read discount from yaml correctly" do
    expect(commit.discount.value).to eq(discount.value)
  end



end
