require 'bundler/gem_tasks'
require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rubocop/rake_task'
require 'rake/testtask'

task 'changelog' do
  args = %w(
    --user=blendle
    --project=cucumber-blendle-steps
    --header-label="# CHANGELOG"
    --bug-labels=type/bug,bug
    --enhancement-labels=type/enhancement,enhancement
    --future-release=unreleased
    --no-verbose
  )

  sh %(github_changelog_generator #{args.join(' ')})
end

RuboCop::RakeTask.new

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --format pretty'
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
end

task default: [:rubocop, :test, :features]
