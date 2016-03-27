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

When(/^I start measuring performance$/) do
  unless @scenario_tags.include?('@performance')
    assert false, 'measuring performance requires the "@performance" tag to be present.'
  end

  step %(I start measuring time)
  step %(I start measuring SQL queries)
end

# Puts the current time in the `@performance_start_time` instance variable. This
# value is then used in the "request time hasn't exceeded x milliseconds" step
# to calculate elapsed time.
#
When(/^I start measuring time$/) do
  unless @scenario_tags.include?('@performance')
    assert false, 'measuring time requires the "@performance" tag to be present.'
  end

  @performance_start_time = Timecop.return { Time.now }
end

# * Then request time hasn't exceeded 100 milliseconds
#
# Note: it is not needed to call the "I stop measuring time" step first. If the
# time recording is still running, it will be stopped during the call of this
# step.
#
Then(/^request time hasn't exceeded (\d+) milliseconds$/) do |milliseconds|
  step('I stop measuring time') unless @performance_stop_time

  elapsed_time = ((@performance_stop_time - @performance_start_time) * 1000.0).to_i

  puts "elapsed time: #{elapsed_time}"
  expect(elapsed_time).to be < milliseconds.to_i
end

# Puts the current time in the `@performance_stop_time` instance variable. This
# value is then used in the "request time hasn't exceeded x milliseconds" step
# to calculate elapsed time.
#
Then(/^I stop measuring time$/) do
  @performance_stop_time = Timecop.return { Time.now }
end

# Starts the DB profiler to measure number of SQL queries made. It also enables
# debug printing of the executed queries.
#
When(/^I start measuring SQL queries/) do
  unless @scenario_tags.include?('@performance')
    assert false, 'counting SQL queries requires the "@performance" tag to be present.'
  end

  DBProfiler.start
end

# * Then exactly 5 database queries have been executed
#
Then(/^exactly (\d+) database queries have been executed/) do |query_count|
  puts "queries counted: #{DBProfiler.query_count}"

  expect(DBProfiler.query_count).to eql(query_count.to_i)
end

# Stops the DBProfiler, resetting the query counter, and disabling debug output
# of executed queries.
#
Then(/^I stop measuring SQL queries$/) do
  DBProfiler.stop
end

Then(/^I stop measuring performance$/) do
  step %(I stop measuring time)
  step %(I stop measuring SQL queries)
end

# After each scenario with the `@performance` tag, the DBProfiler is stopped,
# and all measured request times are reset.
#
After('@performance') do
  DBProfiler.stop

  instance_variable_set(:@performance_stop_time, nil)
  instance_variable_set(:@performance_start_time, nil)
end

# :no-doc:
class DBProfiler
  def self.start
    @count_stringio = StringIO.new
    print_logger = Logger.new($stdout)
    print_logger.formatter = proc { |_, _, _, msg| "#{msg}\n" }
    DB.loggers.concat([print_logger, Logger.new(@count_stringio)])
  end

  def self.stop
    DB.loggers.clear
  end

  def self.queries
    @count_stringio.string.split("\n").map { |n| n.scan(/-- : (.*?)$/).flatten.first }
  end

  def self.single_quoted_queries
    queries.join("\n").tr('"', "'").split("\n")
  end

  def self.queries_only
    single_quoted_queries.select { |n| n =~ /\(\d/ }
  end

  def self.query_count
    queries_only.count
  end
end
