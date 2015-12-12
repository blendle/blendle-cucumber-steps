require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'sequel'

# rubocop:disable Lint/Eval,Metrics/LineLength,Lint/UselessAssignment

# * Given the following items exist:
#     | uid   | price |
#     | hello | 100   |
#     | world | 10    |
#
Given(/^the following (\S+) exist:$/) do |object, table|
  table.hashes.each do |row|
    hash = parse_row(row)

    assert eval("#{object.singularize.capitalize}.create(hash)")
    step %(the following #{object.singularize} should exist:), table([hash.keys, hash.values])
  end
end

# * Given the item with uid "hello" exists
# * Given the item with uid "hello" and price "100" exists
# * Given the item with uid "hello" and the price "100" exists
#
Given(/^the (\S+) with (\S+) "([^"]*)"(?: and(?: the)? (\S+) "([^"]*)")? exists$/) do |object, attribute1, value1, attribute2, value2|
  hash = { attribute1 => value1, attribute2 => value2 }.symbolize_keys.compact

  assert eval("#{object.singularize.capitalize}.create(hash)")
  step %(the following #{object.singularize} should exist:), table([hash.keys, hash.values])
end

# * Given the item with uid "hello" and the following description:
#     """
#     hello world
#     """
#
Given(/^the (\S+) with (\S+) "([^"]*)" and the following (\S+):$/) do |object, attribute1, value1, attribute2, value2|
  hash = { attribute1 => value1, attribute2 => value2 }.symbolize_keys

  assert eval("#{object.singularize.capitalize}.create(hash)")
  step %(the following #{object.singularize} should exist:), table([hash.keys, hash.values])
end

# * Then the item with uid "hello" should exist
# * Then the item with uid "hello" should not exist
# * Then the item with labels (Array) "[10234, 64325]" should exist
#
Then(/^the (\S+) with (\S+)(?: \((\S+)\))? "([^"]*)" should( not)? exist$/) do |object, attribute, type, value, negate|
  hash      = parse_row("#{attribute} (#{type})" => value)
  assertion = negate ? 'blank?' : 'present?'

  assert eval("#{object.capitalize}.first(hash).#{assertion}"),
         %(#{object.capitalize} not found \(#{attribute}: #{value}\))
end

# * Then the following items should exist:
#     | uid   | price |
#     | hello | 100   |
# * Then the following items should not exist:
#
Then(/^the following (\S+) should( not)? exist:$/) do |object, negate, table|
  assertion = negate ? 'blank?' : 'present?'

  table.hashes.each do |row|
    hash = parse_row(row)

    assert eval("#{object.capitalize}.first(hash).#{assertion}")
  end
end

# parse_row
#
# Given a Cucumber table row, parses the type "numbers (Array)" and converts the
# string representation of the value "[1, 2, 3]" into a Sequel pg_array.
#
# @todo Rename method to a more sensible name
# @todo Move method to helper file
# @todo Add more types (Integer)
#
# @param [Object] row in Cucumber::Table
# @return [Hash] hash representation of key/values in table
#
def parse_row(row)
  hash = row.map do |attribute, value|
    value = case attribute[/\s\((\w+)\)$/, 1]
            when 'Array'
              Sequel.pg_array(eval(value))
            else
              value
            end

    [attribute.to_s.split.first.to_sym, value]
  end

  Hash[hash]
end
