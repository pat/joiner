class Joiner::Joins
  JoinDependency = ::ActiveRecord::Associations::JoinDependency

  attr_reader :model

  def initialize(model)
    @model = model
    @joins = ActiveSupport::OrderedHash.new
  end

  def add_join_to(path)
    join_for(path)
  end

  def alias_for(path)
    return model.quoted_table_name if path.empty?

    join_for(path).aliased_table_name
  end

  def join_values
    @joins.values.compact
  end

  private

  def base
    @base ||= JoinDependency.new model, [], []
  end

  def join_for(path)
    @joins[path] ||= begin
      reflection = reflection_for path
      reflection.nil? ? nil : JoinDependency::JoinAssociation.new(
        reflection, base, parent_join_for(path)
      ).tap { |join|
        join.join_type = Arel::OuterJoin

        rewrite_conditions_for join
      }
    end
  end

  def joins_for(path)
    if path.length == 1
      [join_for(path)]
    else
      [joins_for(path[0..-2]), join_for(path)].flatten
    end
  end

  def parent_for(path)
    path.length == 1 ? base : join_for(path[0..-2])
  end

  def parent_join_for(path)
    path.length == 1 ? base.join_base : parent_for(path)
  end

  def reflection_for(path)
    parent = parent_for(path)
    klass  = parent.respond_to?(:base_klass) ? parent.base_klass :
      parent.active_record
    klass.reflections[path.last]
  end

  def rewrite_conditions_for(join)
    if join.respond_to?(:scope_chain)
      conditions = Array(join.scope_chain).flatten
    else
      conditions = Array(join.conditions).flatten
    end

    conditions.each do |condition|
      next unless condition.is_a?(String)

      condition.gsub! /::ts_join_alias::/,
        model.connection.quote_table_name(join.parent.aliased_table_name)
    end
  end
end
