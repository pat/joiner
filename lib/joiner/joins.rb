require 'active_record'
require 'active_support/ordered_hash'

class Joiner::Joins
  attr_reader :model

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
    association_for(path).table.name
  end

  def join_values
    Joiner::JoinDependency.new(
      model, table, joins_cache.to_a, Arel::Nodes::OuterJoin
    )
  end

  private

  attr_reader :joins_cache

  def alias_tracker
    Joiner::AliasTracker.create(
      model.connection, table.name, []
    )
  end

  def association_for(path)
    join_values.join_association_for path, alias_tracker
  end

  def path_as_hash(path)
    path[0..-2].reverse.inject(path.last) { |key, item| {item => key} }
  end

  def table
    @table ||= model.arel_table
  end
end
