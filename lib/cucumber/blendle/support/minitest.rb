# frozen_string_literal: true

require 'minitest'

# :no-doc:
class MinitestWorld
  include Minitest::Assertions
  attr_accessor :assertions

  def initialize
    self.assertions = 0
  end
end

World { MinitestWorld.new }
