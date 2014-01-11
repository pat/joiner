require 'spec_helper'

describe 'Aggregations' do
  it "indicates aggregation for has many associations" do
    joiner = Joiner.new User

    expect(joiner.aggregate_for?([:articles])).to be_true
  end

  it "indicates non-aggregation for belongs to association" do
    joiner = Joiner.new Article

    expect(joiner.aggregate_for?([:user])).to be_false
  end

  it "indicates non-aggregation when the path is empty" do
    joiner = Joiner.new Article

    expect(joiner.aggregate_for?([])).to be_false
  end
end
