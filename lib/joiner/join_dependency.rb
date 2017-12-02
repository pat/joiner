class Joiner::JoinDependency < ActiveRecord::Associations::JoinDependency
  def join_association_for(path)
    path.inject(join_root) do |node, piece|
      node.children.detect { |child| child.reflection.name == piece }
    end
  end
end
