# The core logic of this class is old Rails behaviour, replicated here because
# their own alias logic has evolved, but I haven't yet found a way to make use
# of it - and besides, this is only used to generate Thinking Sphinx's
# configuration rarely - not in any web requests, so performance issues are less
# critical here.

class Joiner::JoinAliaser
  def self.call(join_root, alias_tracker)
    new(join_root, alias_tracker).call
  end

  def initialize(join_root, alias_tracker)
    @join_root = join_root
    @alias_tracker = alias_tracker
  end

  def call
    join_root.each_children do |parent, child|
      child.table = table_aliases_for(parent, child).first
    end
  end

  private

  attr_reader :join_root, :alias_tracker

  def table_aliases_for(parent, node)
    node.reflection.chain.map { |reflection|
      alias_tracker.aliased_table_for(
        reflection.table_name,
        table_alias_for(reflection, parent, reflection != node.reflection),
        reflection.klass.type_caster
      )
    }
  end

  def table_alias_for(reflection, parent, join)
    name = reflection.alias_candidate(parent.table_name)
    join ? "#{name}_join" : name
  end
end
