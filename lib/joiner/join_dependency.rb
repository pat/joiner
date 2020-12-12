class Joiner::JoinDependency < ActiveRecord::Associations::JoinDependency
  def join_association_for(path, alias_tracker = nil)
    @alias_tracker = alias_tracker

    Joiner::JoinAliaser.call join_root, alias_tracker

    path.inject(join_root) do |node, piece|
      node.children.detect { |child| child.reflection.name == piece }
    end
  end
end
