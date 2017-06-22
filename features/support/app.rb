# frozen_string_literal: true

require 'sequel'

DB = Sequel.sqlite
DB.create_table :items do
  primary_key :id
  String :uid
end

require_relative '../fixtures/app'
include CucumberBlendleSteps

App = Webmachine::Application.new do |app|
  app.routes do
    add ['item', :item_uid], ItemResource
  end

  app.configure do |config|
    config.adapter = :Rack
  end
end

def app
  App.adapter
end
