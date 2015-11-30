require 'cucumber/blendle_steps'
require 'rack'
require 'rack/test'
require 'sequel'

DB = Sequel.sqlite
DB.create_table :items do
  primary_key :id
  String :uid
end

require_relative '../fixtures/fake_app/item_resource'
include CucumberBlendleSteps

def app
  App.adapter
end
