require 'active_record'
require 'active_support/ordered_hash'

class Joiner::Joins
  JoinDependency = ::ActiveRecord::Associations::JoinDependency

  attr_reader :model
  attr_writer :join_association_class

  def initialize(model)
    @model       = model
    @base        = JoinDependency.new model, [], []
    @joins_cache = ActiveSupport::OrderedHash.new
  end

  def add_join_to(path)
    @joins_cache[path] ||= build_join(path)
  end

  def alias_for(path)
    return model.table_name if path.empty?
    add_join_to(path).aliased_table_name
  end

  def join_association_class
    @join_association_class || JoinDependency::JoinAssociation
  end

  def join_values
    @base
  end

  private

  def build_join(path)
    if join = find_join(path)
      return join
    end

    base_node, short_path = relative_path(path)

    join = build_join_association(short_path, base_node.base_klass)
    base_node.children << join
    construct_tables! base_node, join

    find_join(path)
  end

  def build_join_association(path, base_class)
    return nil if path.empty?

    step = path.first
    reflection = find_reflection(step, base_class)
    reflection.check_validity!

    join_association_class.new reflection,
      [build_join_association(path[1..-1], reflection.klass)].compact
  end

  def find_join(path, base = nil)
    base ||= @base.join_root

    return base if path.empty?

    if next_step = base.children.detect{ |c| c.reflection.name == path.first }
      find_join path[1..-1], next_step
    end
  end

  def relative_path(path)
    short_path = []
    test_path = path.dup

    while test_path.size > 1
      short_path << test_path.pop
      node = find_join(test_path)
      return [node, short_path] if node
    end

    [@base.join_root, path]
  end

  def find_reflection(name, klass)
    klass._reflect_on_association(name)
  end

  def table_aliases_for(parent, node)
    node.reflection.chain.map { |reflection|
      @base.alias_tracker.aliased_table_for(
        reflection.table_name,
        table_alias_for(reflection, parent, reflection != node.reflection)
      )
    }
  end

  def construct_tables!(parent, node)
    node.tables = table_aliases_for(parent, node)
    node.children.each { |child| construct_tables! node, child }
  end

  def table_alias_for(reflection, parent, join)
    name = "#{reflection.plural_name}_#{parent.table_name}"
    name << "_join" if join
    name
  end
end
