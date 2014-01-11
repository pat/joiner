require 'spec_helper'

describe 'Paths' do
  describe 'Aggregations' do
    it "indicates aggregation for has many associations" do
      path = Joiner::Path.new User, [:articles]

      expect(path).to be_aggregate
    end

    it "indicates non-aggregation for belongs to association" do
      path = Joiner::Path.new Article, [:user]

      expect(path).to_not be_aggregate
    end

    it "indicates non-aggregation when the path is empty" do
      path = Joiner::Path.new Article, []

      expect(path).to_not be_aggregate
    end
  end

  describe 'models' do
    it "determines the underlying model for an association path" do
      path = Joiner::Path.new User, [:articles, :comments]

      expect(path.model).to eq(Comment)
    end

    it "returns the base model if the path is empty" do
      path = Joiner::Path.new User, []

      expect(path.model).to eq(User)
    end

    it "raises an exception if the path is invalid" do
      path = Joiner::Path.new User, [:articles, :likes]

      expect { path.model }.to raise_error(Joiner::AssociationNotFound)
    end
  end
end
