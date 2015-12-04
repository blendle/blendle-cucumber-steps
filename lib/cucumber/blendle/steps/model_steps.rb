require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'sequel'

# rubocop:disable Lint/Eval,Metrics/LineLength,Lint/UselessAssignment

Given(/^the following (\S+) exist:$/) do |object, table|
  table.hashes.each do |row|
    hash = parse_row(row)

    assert eval("#{object.singularize.capitalize}.create(hash)")
    step %(the following #{object.singularize} should exist:), table([hash.keys, hash.values])
  end
end

Then(/^the (\S+) with (\S+)(?: \((\S+)\))? "([^"]*)" should( not)? exist$/) do |object, attribute, type, value, negate|
  hash      = parse_row("#{attribute} (#{type})" => value)
  assertion = negate ? 'blank?' : 'present?'

  assert eval("#{object.capitalize}.first(hash).#{assertion}"),
         %(#{object.capitalize} not found \(#{attribute}: #{value}\))
end

Then(/^the following (\S+) should( not)? exist:$/) do |object, negate, table|
  assertion = negate ? 'blank?' : 'present?'

  table.hashes.each do |row|
    hash = parse_row(row)

    assert eval("#{object.capitalize}.first(hash).#{assertion}")
  end
end

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
