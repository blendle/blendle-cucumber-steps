# rubocop:disable Metrics/LineLength

require 'halidator'
require 'rack/utils'

# * When the client does a GET request to "/items"
#
When('the client does a GET request to "$1"') do |path|
  get(path, {}, {})
end

# * When the client provides the header "Accept: application/hal+json"
#
When(/^the client provides the header ["']([^"']*)["']$/) do |header|
  name, value = header.split(/\s*:\s*/)
  header(name, value)
end

# * When the client does a DELETE request to "/item/hello"
#
When(/^the client does a (POST|DELETE) request to "([^"]*)"$/) do |method, path|
  send(method.downcase, path, {})
end

# * When the client does a POST request to "/items" with the following content:
#   """json
#   {
#     "uid": "hello",
#     "price": 100
#   }
#   """
#
When(/^the client does a (POST|PUT) request to "([^"]*)" with the following content:$/) do |method, path, content|
  send(method.downcase, path, content.strip)
end

# * Then the status code should be "200" (OK)
# * Then the status code should be "204" (No Content)
#
Then(/^the status code should be "(\d+)" \((.+)\)/) do |status_code, status_message|
  assert_equal status_code.to_i, last_response.status, last_response.body
  assert_equal status_message, Rack::Utils::HTTP_STATUS_CODES[status_code.to_i]
end

# * Then the response should contain the header "Location" with value "https://example.org/item/hello"
#
Then(/^the response should contain the header "([^"]*)" with value "([^"]*)"$/) do |header, value|
  assert_equal last_response.headers[header], value
end

# * Then the response should be of type "application/json" with content:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
#
Then(/^the response should be of type "([^"]*)" with content:$/) do |content_type, content|
  dump last_response.body

  assert_equal content_type, last_response.headers['Content-Type']
  assert_equal content, last_response.body
end

# * Then the response should be JSON:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
Then(/^the response should be JSON:$/) do |json|
  dump last_response.body

  assert_equal last_response.headers['Content-Type'], 'application/json'
  expect(last_response.body).to be_json_eql(json)
end

# * Then the response should be HAL/JSON:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
# * Then the response should be HAL/JSON (disregarding value of "random_id"):
#     """json
#     {
#       "uid": "hello",
#       "random_id": 57303667592
#     }
#     """
#
Then(%r{^the response should be HAL/JSON(?: \(disregarding values? of "([^"]*)"\))?:$}) do |disregard, json|
  dump last_response.body

  assert_match %r{^application/hal\+json(;.*)?$}, last_response.headers['Content-Type']

  hal = nil
  begin
    hal = Halidator.new(last_response.body)
  rescue JSON::ParserError => e
    assert false, [e.message, last_response.body].join("\n")
  end

  assert hal.valid?, "Halidator errors: #{hal.errors.join(',')}"

  match = be_json_eql(json)
  if disregard.present?
    disregard.split(',').each do |attribute|
      match = match.excluding(attribute)
    end
  end

  expect(last_response.body).to match
end

# * Then the response contains the "Location" header with value "https://example.org/item/hello"
#
Then(/^the response contains the "(.*?)" header with value "(.*?)"$/) do |header, value|
  assert_equal value, last_response.headers[header]
end
