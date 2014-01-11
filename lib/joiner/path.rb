class Joiner::Path
  AGGREGATE_MACROS = [:has_many, :has_and_belongs_to_many]

  def initialize(base, path)
    @base, @path = base, path
  end

  def aggregate?
    macros.any? { |macro| AGGREGATE_MACROS.include? macro }
  end

  def macros
    reflections.collect(&:macro)
  end

  def model
    path.empty? ? base : reflections.last.try(:klass)
  end

  private

  attr_reader :base, :path

  def reflections
    klass = base
    path.collect { |reference|
      klass.reflect_on_association(reference).tap { |reflection|
        if reflection.nil?
          raise Joiner::AssociationNotFound,
            "No association matching #{base.name}, #{path.join(', ')}"
        end

        klass = reflection.klass
      }
    }
  end
end
