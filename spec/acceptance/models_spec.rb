require 'spec_helper'

describe 'Association path models' do
  it "determines the underlying model for an association path" do
    joiner = Joiner.new User

    expect(joiner.model_for([:articles, :comments])).to eq(Comment)
  end

  it "returns the base model if the path is empty" do
    joiner = Joiner.new User

    expect(joiner.model_for([])).to eq(User)
  end
end
