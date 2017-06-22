# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'chronic'
require 'sequel'

# rubocop:disable Lint/Eval,Metrics/LineLength,Lint/UselessAssignment

# * Given the following items exist:
#     | uid   | price |
#     | hello | 100   |
#     | world | 10    |
#
Given(/^the following ((?:(?!should).)+) exist:$/) do |object, table|
  table.hashes.each do |row|
    hash = parse_row(row, object)

    assert eval("#{object.tr(' ', '_').singularize.classify}.create(hash)")
    step %(the following #{object} should exist:), table([hash.keys, hash.values])
  end
end

# * Given the item with uid "hello" exists
# * Given the item with uid "hello" and price "100" exists
# * Given the item with uid "hello" and the price "100" exists
#
Given(/^the (\S+) with (\S+) "([^"]*)"(?: and(?: the)? (\S+) "([^"]*)")? exists$/) do |object, attribute1, value1, attribute2, value2|
  hash = { attribute1 => value1, attribute2 => value2 }.symbolize_keys.compact

  assert eval("#{object.tr(' ', '_').singularize.classify}.create(hash)")
  step %(the following #{object} should exist:), table([hash.keys, hash.values])
end

# * Given the item with uid "hello" and the following description:
#     """
#     hello world
#     """
#
Given(/^the (\S+) with (\S+) "([^"]*)" and the following (\S+):$/) do |object, attribute1, value1, attribute2, value2|
  hash = { attribute1 => value1, attribute2 => value2 }.symbolize_keys

  assert eval("#{object.tr(' ', '_').singularize.classify}.create(hash)")
  step %(the following #{object} should exist:), table([hash.keys, hash.values])
end

# * Then the item with uid "hello" should exist
# * Then the item with uid "hello" should not exist
#
Then(/^the (\S+) with (\S+) "([^"]*)" should( not)? exist$/) do |object, attribute, value, negate|
  assertion = negate ? 'blank?' : 'present?'
  hash      = parse_row({ attribute => value }, object)
  klass     = object.tr(' ', '_').singularize.classify

  assert eval("row_finder(klass, hash).#{assertion}"),
         %(#{object.capitalize} not found \(#{attribute}: #{value}\))
end

# * Then the following items should exist:
#     | uid   | price |
#     | hello | 100   |
# * Then the following items should not exist:
#
Then(/^the following (.+)? should( not)? exist:$/) do |object, negate, table|
  assertion = negate ? 'blank?' : 'present?'

  table.hashes.each do |row|
    hash = parse_row(row, object)
    klass = object.tr(' ', '_').singularize.classify

    assert eval("row_finder(klass, hash).#{assertion}"),
           "Could not find requested #{object}:\n\n" \
           "- #{hash}\n" \
           "+ #{Object.const_get(klass).all.map(&:values).join("\n+ ")}"
  end
end

# * Then there should be 5 item records
# * Then there should be 1 item record
# * Then there should be 0 item records
#
Then(/^there should be (\d+) (.+)? records?$/) do |count, object|
  count = count.to_i
  klass = object.tr(' ', '_').singularize.classify

  assert_equal(count, klass.constantize.count)
end

# parse_row
#
# Given a Cucumber table row, parses the type "numbers (Array)" and converts the
# string representation of the value "[1, 2, 3]" into a Sequel pg_array.
#
# @param [Object] row in Cucumber::Table
# @param [String] object_name to be parsed
# @return [Hash] hash representation of key/values in table
#
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
#
def parse_row(row, object_name)
  table  = object_name.tr(' ', '_')
  klass  = Object.const_get(table.singularize.classify)
  schema = klass.db.schema(klass.table_name)

  hash = row.map do |attribute, value|
    column = schema.reverse.find { |c| c.first.to_s == attribute.to_s } || []

    next [attribute.to_sym, Sequel.pg_array(value)] if value.is_a?(Array)
    next [attribute.to_sym, value] unless value.is_a?(String)
    next [attribute.to_sym, nil] if value == 'NULL'

    value = case column.last.to_h[:type]
            when :integer
              value.to_i
            when :datetime
              Timecop.return { Chronic.parse(value) || DateTime.parse(value) }
            when :boolean
              value.to_s.casecmp('true').zero?
            when :string_array, :varchar_array, :bigint_array, :integer_array
              Sequel.pg_array(eval(value))
            when :jsonb
              Sequel.pg_jsonb(eval(value))
            when :hstore
              Sequel.hstore(eval(value))
            else
              value
            end

    [attribute.to_sym, value]
  end

  Hash[hash]
end

def row_finder(klass, hash)
  ext = 'where'
  query = hash.each_with_object({}) do |(key, value), q|
    if defined?(Sequel::Postgres::JSONBHash) && value.is_a?(Sequel::Postgres::JSONBHash)
      ext = "where { Sequel.pg_jsonb(:#{key}).contains(#{value}) }"
    else
      q[key] = value
    end
  end

  eval "#{klass}.#{ext}.first(query)"
end
