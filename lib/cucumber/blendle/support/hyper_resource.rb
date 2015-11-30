require 'hyperresource'

def HyperResource.from_body(body)
  root = body['_links']['self']['href']
  api = HyperResource.new(root: root, href: root)
  api.body = body
  api.adapter.apply(body, api)
  api.loaded = true
  api
end
