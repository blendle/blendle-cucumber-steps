require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

# rubocop:disable Lint/Eval
# rubocop:disable Lint/UnusedBlockArgument

Given(/^the following (\S+) exist:$/) do |object, table|
  table.hashes.each do |row|
    assert eval("#{object.singularize.capitalize}.create(row.symbolize_keys)")
    step %(the following #{object.singularize} should exist:), table([row.keys, row.values])
  end
end

Then(/^the (\S+) with (\S+) "([^"]*)" should( not)? exist$/) do |object, attribute, negate, value|
  assertion = negate ? 'blank?' : 'present?'

  assert eval("#{object.capitalize}.first(attribute.to_sym => value).#{assertion}")
end

Then(/^the following (\S+) should( not)? exist:$/) do |object, negate, table|
  assertion = negate ? 'blank?' : 'present?'

  table.hashes.each do |row|
    assert eval("#{object.capitalize}.first(row.symbolize_keys).#{assertion}")
  end
end
