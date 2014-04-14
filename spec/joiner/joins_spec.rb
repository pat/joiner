require 'spec_helper'

describe Joiner::Joins do
  JoinDependency = ::ActiveRecord::Associations::JoinDependency

  subject { Joiner::Joins.new Article }

  describe '#add_join_to' do
    it "adds just one join for a stack with a single association" do
      JoinDependency::JoinAssociation.should_receive(:new).
        with(Article.reflections[:user], []).once.and_call_original

      subject.add_join_to([:user])
    end

    it "does not duplicate joins when given the same stack twice" do
      JoinDependency::JoinAssociation.should_receive(:new).once.and_call_original

      subject.add_join_to([:user])
      subject.add_join_to([:user])
    end

    context 'when joins are nested' do
      it "adds two joins for a stack with two associations" do
        JoinDependency::JoinAssociation.should_receive(:new).
          with(Article.reflections[:user], kind_of(Array)).once.and_call_original
        JoinDependency::JoinAssociation.should_receive(:new).
          with(User.reflections[:comments], kind_of(Array)).once.and_call_original

        subject.add_join_to([:user, :comments])
      end

      it "extends upon existing joins when given stacks where parts are already mapped" do
        JoinDependency::JoinAssociation.should_receive(:new).twice.and_call_original

        join1 = subject.add_join_to([:user])
        join2 = subject.add_join_to([:user, :comments])

        join1.children.should include(join2)
      end
    end
  end

  describe '#alias_for' do
    it "returns the model's table name when no stack is given" do
      subject.alias_for([]).should == 'articles'
    end

    it "gets join association using #add_join_to" do
      subject.should_receive(:add_join_to).with([:user]).and_call_original
      subject.alias_for([:user])
    end

    it "returns the aliased table name for the join" do
      subject.alias_for([:user]).should == 'users'
    end

    it "does not duplicate joins when given the same stack twice" do
      JoinDependency::JoinAssociation.should_receive(:new).once.and_call_original

      subject.alias_for([:user])
      subject.alias_for([:user])
    end

    context 'when joins are nested' do
      it "returns the sub join's aliased table name" do
        subject.alias_for([:user, :comments]).should == 'comments'
      end
    end
  end

  describe '#join_values' do
    it "returns JoinDependency with all joins that have been created" do
      join1 = subject.add_join_to([:user])
      join2 = subject.add_join_to([:comments])
      join3 = subject.add_join_to([:comments, :user])

      join_values = subject.join_values
      join_values.should be_a JoinDependency
      join_values.join_root.children.should == [join1, join2]
    end
  end
end
