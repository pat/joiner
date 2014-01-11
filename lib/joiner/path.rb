class Joiner::Path
  AGGREGATE_MACROS = [:has_many, :has_and_belongs_to_many]

  def initialize(base, stack)
    @base, @stack = base, stack
  end

  def aggregate?
    macros.any? { |macro| AGGREGATE_MACROS.include? macro }
  end

  def macros
    reflections.collect(&:macro)
  end

  def model
    stack.empty? ? base : reflections.last.try(:klass)
  end

  private

  attr_reader :base, :stack

  def reflections
    klass = base
    stack.collect { |reference|
      klass.reflect_on_association(reference).tap { |reflection|
        return [] if reflection.nil?
        klass = reflection.klass
      }
    }
  end
end
