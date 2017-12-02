require 'active_record'
require 'active_support/ordered_hash'

class Joiner::Joins
  JoinDependency  = ActiveRecord::Associations::JoinDependency
  JoinAssociation = JoinDependency::JoinAssociation

  attr_reader   :model
  attr_accessor :join_association_class

  def initialize(model)
    @model       = model
    @joins_cache = Set.new
  end

  def add_join_to(path)
    return if path.empty?

    joins_cache.add path_as_hash(path)
  end

  def alias_for(path)
    return model.table_name if path.empty?

    add_join_to path
    join_values.join_association_for(path).tables.first.name
  end

  def join_values
    switch_join_dependency join_association_class
    result = Joiner::JoinDependency.new model, table, joins_cache.to_a, alias_tracker
    switch_join_dependency JoinAssociation

    result
  end

  private

  attr_reader :joins_cache

  def alias_tracker
    ActiveRecord::Associations::AliasTracker.create(
      model.connection, table.name, []
    )
  end

  def path_as_hash(path)
    path[0..-2].reverse.inject(path.last) { |key, item| {item => key} }
  end

  def switch_join_dependency(klass)
    return unless join_association_class

    JoinDependency.send :remove_const, :JoinAssociation
    JoinDependency.const_set :JoinAssociation, klass
  end

  def table
    @table ||= model.arel_table
  end
end
