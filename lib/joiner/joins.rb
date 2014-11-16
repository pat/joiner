class Joiner::Joins
  JoinDependency = ::ActiveRecord::Associations::JoinDependency

  attr_reader :model
  attr_writer :join_association_class

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
    join_association_for(path).tables.first.name
  end

  def join_association_class
    @join_association_class || JoinDependency::JoinAssociation
  end

  def join_values
    JoinDependency.new model, joins_cache.to_a, []
  end

  private

  attr_reader :joins_cache

  def join_association_for(path)
    path.inject(join_values.join_root) do |node, piece|
      node.children.detect { |child| child.reflection.name == piece }
    end
  end

  def path_as_hash(path)
    ending = path.last
    path[0..-2].reverse.inject(ending) do |key, item|
      {item => key}
    end
  end
end
