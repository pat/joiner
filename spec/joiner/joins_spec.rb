require 'spec_helper'

describe Joiner::Joins do
  JoinDependency = ::ActiveRecord::Associations::JoinDependency

  let(:joins)     { Joiner::Joins.new model }
  let(:model)     { model_double 'articles' }
  let(:base)      {
    double('base', :active_record => model, :join_base => join_base)
  }
  let(:join_base) { double('join base') }
  let(:join)      { join_double 'users' }
  let(:sub_join)  { join_double 'posts' }

  def join_double(table_alias)
    double 'join',
      :join_type=         => nil,
      :aliased_table_name => table_alias,
      :reflection         => double('reflection'),
      :conditions         => []
  end

  def model_double(table_name = nil)
    double 'model', :quoted_table_name => table_name, :reflections => {}
  end

  before :each do
    JoinDependency.stub :new => base
    JoinDependency::JoinAssociation.stub(:new).and_return(join, sub_join)
    model.reflections[:user] = join.reflection

    join.stub :active_record => model_double
    join.active_record.reflections[:posts] = sub_join.reflection
  end

  describe '#add_join_to' do
    before :each do
      JoinDependency::JoinAssociation.unstub :new
    end

    it "adds just one join for a stack with a single association" do
      JoinDependency::JoinAssociation.should_receive(:new).
        with(join.reflection, base, join_base).once.and_return(join)

      joins.add_join_to([:user])
    end

    it "does not duplicate joins when given the same stack twice" do
      JoinDependency::JoinAssociation.should_receive(:new).once.and_return(join)

      joins.add_join_to([:user])
      joins.add_join_to([:user])
    end

    context 'multiple joins' do
      it "adds two joins for a stack with two associations" do
        JoinDependency::JoinAssociation.should_receive(:new).
          with(join.reflection, base, join_base).once.and_return(join)
        JoinDependency::JoinAssociation.should_receive(:new).
          with(sub_join.reflection, base, join).once.and_return(sub_join)

        joins.add_join_to([:user, :posts])
      end

      it "extends upon existing joins when given stacks where parts are already mapped" do
        JoinDependency::JoinAssociation.should_receive(:new).twice.
          and_return(join, sub_join)

        joins.add_join_to([:user])
        joins.add_join_to([:user, :posts])
      end
    end

    context 'join with conditions' do
      let(:connection) { double }
      let(:parent)     { double :aliased_table_name => 'qux' }

      before :each do
        JoinDependency::JoinAssociation.stub :new => join

        join.stub :parent => parent
        model.stub :connection => connection
        connection.stub(:quote_table_name) { |table| "\"#{table}\"" }
      end

      it "leaves standard conditions untouched" do
        join.stub :conditions => 'foo = bar'

        joins.add_join_to [:user]

        join.conditions.should == 'foo = bar'
      end

      it "modifies filtered polymorphic conditions" do
        join.stub :conditions => '::ts_join_alias::.foo = bar'

        joins.add_join_to [:user]

        join.conditions.should == '"qux".foo = bar'
      end

      it "modifies filtered polymorphic conditions within arrays" do
        join.stub :conditions => ['::ts_join_alias::.foo = bar']

        joins.add_join_to [:user]

        join.conditions.should == ['"qux".foo = bar']
      end

      it "does not modify conditions as hashes" do
        join.stub :conditions => [{:foo => 'bar'}]

        joins.add_join_to [:user]

        join.conditions.should == [{:foo => 'bar'}]
      end
    end
  end

  describe '#alias_for' do
    it "returns the model's table name when no stack is given" do
      joins.alias_for([]).should == 'articles'
    end

    it "adds just one join for a stack with a single association" do
      JoinDependency::JoinAssociation.unstub :new
      JoinDependency::JoinAssociation.should_receive(:new).
        with(join.reflection, base, join_base).once.and_return(join)

      joins.alias_for([:user])
    end

    it "returns the aliased table name for the join" do
      joins.alias_for([:user]).should == 'users'
    end

    it "does not duplicate joins when given the same stack twice" do
      JoinDependency::JoinAssociation.unstub :new
      JoinDependency::JoinAssociation.should_receive(:new).once.and_return(join)

      joins.alias_for([:user])
      joins.alias_for([:user])
    end

    context 'multiple joins' do
      it "adds two joins for a stack with two associations" do
        JoinDependency::JoinAssociation.unstub :new
        JoinDependency::JoinAssociation.should_receive(:new).
          with(join.reflection, base, join_base).once.and_return(join)
        JoinDependency::JoinAssociation.should_receive(:new).
          with(sub_join.reflection, base, join).once.and_return(sub_join)

        joins.alias_for([:user, :posts])
      end

      it "returns the sub join's aliased table name" do
        joins.alias_for([:user, :posts]).should == 'posts'
      end

      it "extends upon existing joins when given stacks where parts are already mapped" do
        JoinDependency::JoinAssociation.unstub :new
        JoinDependency::JoinAssociation.should_receive(:new).twice.
          and_return(join, sub_join)

        joins.alias_for([:user])
        joins.alias_for([:user, :posts])
      end
    end
  end

  describe '#join_values' do
    it "returns all joins that have been created" do
      joins.alias_for([:user])
      joins.alias_for([:user, :posts])

      joins.join_values.should == [join, sub_join]
    end
  end
end
