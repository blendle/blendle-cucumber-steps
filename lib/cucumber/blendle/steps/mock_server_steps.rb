require 'net/http'
require 'json'

# * Given the following endpoint configurations:
#     | service      | endpoint     | method | status |
#     | subscription | /hello/world | GET    | 200    |
#     | core         | /hello       | POST   | 204    |
#
# This step definition is dependent on the mock-server implementation available
# at https://github.com/eterps/mock-server. You need to set the
# `MOCK_ENDPOINT_HOST` environment variable for this step to work.
#
Given(/^the following endpoint configurations:$/) do |table|
  unless ENV['MOCK_ENDPOINT_HOST']
    puts 'environment variable missing: MOCK_ENDPOINT_HOST'
    next pending
  end

  table.hashes.each do |row|
    payload = { request: {}, response: {} }

    %i(method endpoint).each do |option|
      payload[:request][option.to_sym] = row[option.to_s]
    end

    %i(status headers body).each do |option|
      payload[:response][option.to_sym] = row[option.to_s]
    end

    payload[:request][:endpoint] = File.join(row['service'], payload[:request][:endpoint])
    Net::HTTP.start(ENV['MOCK_ENDPOINT_HOST']).post('/mock/_mocks', payload.to_json)
  end
end
