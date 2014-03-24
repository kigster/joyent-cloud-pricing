require 'spec_helper'

describe 'Joyent::Cloud::Pricing::Commit' do
  let(:commit) { Joyent::Cloud::Pricing::Commit.from_yaml 'spec/fixtures/commit.yml' }

  let(:expected_commit) { {
      "g3-highcpu-32-smartos-cc" => {prepay: 8000.0, monthly: 500.0, years: 1},
      "g3-highmemory-17.125-smartos" => {prepay: 800.0, monthly: 60.0, years: 1}
  } }

  it "should correctly load commit from the file" do
    expected_commit.keys.each do |flavor|
      expect(expected_commit[flavor]).to eql(commit.reserve_for(flavor).to_hash)
    end
  end

end
