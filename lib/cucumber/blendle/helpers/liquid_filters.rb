# frozen_string_literal: true

require 'liquid'
require 'chronic'
require 'time'

module Cucumber
  module BlendleSteps
    # :no-doc:
    class LiquidFilters
      # :no-doc:
      module Date
        def date(input)
          Timecop.return { Chronic.parse(input) || DateTime.parse(input) }.utc.iso8601
        end
      end

      Liquid::Template.register_filter(Date)
    end
  end
end
