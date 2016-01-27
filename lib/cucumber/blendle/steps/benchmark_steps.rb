require 'typhoeus'

def last_requests # rubocop:disable Style/TrivialAccessors
  @last_requests
end

# * When the client does 1000 concurrent GET request to "https://example.org/items"
#
When(/^the client does (\d+) concurrent GET requests to "([^"]*)"$/) do |count, url|
  hydra = Typhoeus::Hydra.new
  @last_requests = Array.new(count.to_i) do
    request = Typhoeus::Request.new(url, followlocation: true)
    hydra.queue(request)
    request
  end

  hydra.run

  @last_requests.map!(&:response)
end

Then(/^all requests should have succeeded$/) do
  last_requests.map(&:code).any? { |status| status.to_s[0] != 2 }
end
