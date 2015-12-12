require 'webmachine'
require 'webmachine/adapters/rack'

# CucumberBlendleSteps
#
# Test setup to verify working Cucumber step definitions.
#
module CucumberBlendleSteps
  class Item < Sequel::Model
  end

  # :no-doc:
  class ItemResource < Webmachine::Resource
    def allowed_methods
      %w(GET)
    end

    def content_types_provided
      [['application/hal+json', :to_json]]
    end

    def resource_exists?
      item.present?
    end

    def to_json
      item.values.merge(_links: { self: { href: "https://example.org/item/#{item.uid}" } }).to_json
    end

    private

    def params
      JSON.parse(request.body.to_s)
    rescue JSON::ParserError
      {}
    end

    def item
      @item ||= Item.first(uid: item_uid)
    end

    def item_uid
      request.path_info[:item_uid]
    end
  end
end
