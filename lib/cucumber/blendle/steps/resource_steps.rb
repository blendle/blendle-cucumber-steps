# rubocop:disable Metrics/LineLength

When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource$/) do |method, resource|
  step %(the client does a #{method} request to the "#{resource}" resource with these parameters:), table([[]])
end

When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with the template variable "([^"]*)" set to "([^"]*)"$/) do |method, resource, key, value|
  tables = [%w(key value), [key, value]]

  step %(the client does a #{method} request to the "#{resource}" resource with these parameters:), table(tables)
end

When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with these parameters:$/) do |method, resource, table|
  params = {}
  current_accept_header = current_session.instance_variable_get(:@headers)['Accept']

  step %(the client provides the header "Accept: application/hal+json")
  body = JSON.parse(get('/api').body)

  if current_accept_header
    step %(the client provides the header "Accept: #{current_accept_header}")
  end

  table && table.hashes.each do |row|
    params[row['key']] = row['value']
  end

  api = HyperResource.from_body(body)
  url = api.send(resource, params).href
  step %(the client does a #{method} request to "#{url}")
end

When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with the following content:$/) do |method, resource, content|
  body = JSON.parse(get('/api').body)
  api  = HyperResource.from_body(body)
  url  = api.send(resource, {}).href

  step %(the client does a #{method} request to "#{url}" with the following content:), content
end

When(/^the client does a (POST|PUT) request to the "([^"]*)" resource with the template variable "([^"]*)" set to "([^"]*)" and the following content:$/) do |method, resource, key, value, content|
  body = JSON.parse(get('/api').body)
  api  = HyperResource.from_body(body)
  url  = api.send(resource, key => value).href

  step %(the client does a #{method} request to "#{url}" with the following content:), content
end
