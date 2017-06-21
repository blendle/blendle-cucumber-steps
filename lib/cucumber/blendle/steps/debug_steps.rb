# frozen_string_literal: true

# * Then I want to pry
# * Then I want to debug
#
Then(/^I want to (?:pry|debug)$/) do
  require 'pry'; binding.pry # rubocop:disable Lint/Debugger,Style/Semicolon
end
