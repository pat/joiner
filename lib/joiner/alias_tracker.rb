# frozen_string_literal: true

require "active_support/core_ext/string/conversions"

# This code is taken straight from Rails, prior to v6.1.0.
# I'm maintaining a copy here to save myself having to work through aliasing
# logic myself - there's a good chance I don't need all of this, but it'll do
# to get this gem working with Rails 6.1.

class Joiner::AliasTracker # :nodoc:
  def self.create(connection, initial_table, joins, aliases = nil)
    if joins.empty?
      aliases ||= Hash.new(0)
    elsif aliases
      default_proc = aliases.default_proc || proc { 0 }
      aliases.default_proc = proc { |h, k|
        h[k] = initial_count_for(connection, k, joins) + default_proc.call(h, k)
      }
    else
      aliases = Hash.new { |h, k|
        h[k] = initial_count_for(connection, k, joins)
      }
    end
    aliases[initial_table] = 1
    new(connection, aliases)
  end

  def self.initial_count_for(connection, name, table_joins)
    quoted_name = nil

    counts = table_joins.map do |join|
      if join.is_a?(Arel::Nodes::StringJoin)
        # quoted_name should be case ignored as some database adapters (Oracle) return quoted name in uppercase
        quoted_name ||= connection.quote_table_name(name)

        # Table names + table aliases
        join.left.scan(
          /JOIN(?:\s+\w+)?\s+(?:\S+\s+)?(?:#{quoted_name}|#{name})\sON/i
        ).size
      elsif join.is_a?(Arel::Nodes::Join)
        join.left.name == name ? 1 : 0
      else
        raise ArgumentError, "joins list should be initialized by list of Arel::Nodes::Join"
      end
    end

    counts.sum
  end

  # table_joins is an array of arel joins which might conflict with the aliases we assign here
  def initialize(connection, aliases)
    @aliases    = aliases
    @connection = connection
  end

  def aliased_table_for(table_name, aliased_name, type_caster)
    if aliases[table_name].zero?
      # If it's zero, we can have our table_name
      aliases[table_name] = 1
      Arel::Table.new(table_name, type_caster: type_caster)
    else
      # Otherwise, we need to use an alias
      aliased_name = @connection.table_alias_for(aliased_name)

      # Update the count
      aliases[aliased_name] += 1

      table_alias = if aliases[aliased_name] > 1
        "#{truncate(aliased_name)}_#{aliases[aliased_name]}"
      else
        aliased_name
      end
      Arel::Table.new(table_name, type_caster: type_caster).alias(table_alias)
    end
  end

  attr_reader :aliases

  private

  def truncate(name)
    name.slice(0, @connection.table_alias_length - 2)
  end
end
