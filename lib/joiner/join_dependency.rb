class Joiner::JoinDependency < ActiveRecord::Associations::JoinDependency
  def join_association_for(path, alias_tracker = nil)
    if alias_tracker
      # ActiveRecord 5.2.1+
      @alias_tracker = alias_tracker
      construct_tables! join_root
    end

    path.inject(join_root) do |node, piece|
      node.children.detect { |child| child.reflection.name == piece }
    end
  end
end
