require 'spec_helper'

describe 'Joiner' do
  it "handles has many associations" do
    joiner = Joiner::Joins.new User
    joiner.add_join_to [:articles]

    sql = User.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"articles\"/)
  end

  it "handles multiple has many associations separately" do
    joiner = Joiner::Joins.new User
    joiner.add_join_to [:articles]
    joiner.add_join_to [:articles, :comments]

    sql = User.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"articles\"/)
    expect(sql).to match(/LEFT OUTER JOIN \"comments\"/)
  end

  it "handles multiple has many associations together" do
    joiner = Joiner::Joins.new User
    joiner.add_join_to [:articles, :comments]

    sql = User.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"articles\"/)
    expect(sql).to match(/LEFT OUTER JOIN \"comments\"/)
  end

  it "handles a belongs to association" do
    joiner = Joiner::Joins.new Comment
    joiner.add_join_to [:article]

    sql = Comment.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"articles\"/)
  end

  it "handles both belongs to and has many associations separately" do
    joiner = Joiner::Joins.new Article
    joiner.add_join_to [:user]
    joiner.add_join_to [:comments]

    sql = Article.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"users\"/)
    expect(sql).to match(/LEFT OUTER JOIN \"comments\"/)
  end

  it "handles both belongs to and has many associations together" do
    joiner = Joiner::Joins.new Article
    joiner.add_join_to [:user, :comments]

    sql = Article.joins(joiner.join_values).to_sql
    expect(sql).to match(/LEFT OUTER JOIN \"users\"/)
    expect(sql).to match(/LEFT OUTER JOIN \"comments\"/)
  end

  it "distinguishes joins via different relationships" do
    joiner = Joiner::Joins.new Article
    joiner.add_join_to [:comments]
    joiner.add_join_to [:user, :comments]

    expect(joiner.alias_for([:comments])).to eq('comments')
    expect(joiner.alias_for([:user, :comments])).to eq('comments_users')
  end

  it 'handles simple and deep chains' do
    joiner = Joiner::Joins.new Article
    joiner.add_join_to [:comments]
    joiner.add_join_to [:comments, :user, :articles]

    expect(joiner.alias_for([:comments])).to eq('comments')
    expect(joiner.alias_for([:comments, :user, :articles])).to eq(
      'articles_users'
    )
  end
end
