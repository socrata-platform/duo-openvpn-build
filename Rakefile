# Encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'

RuboCop::RakeTask.new

FoodCritic::Rake::LintTask.new do |f|
  f.options = { fail_tags: %w(any) }
end

RSpec::Core::RakeTask.new(:spec)

Kitchen::RakeTasks.new

task default: %w(rubocop foodcritic spec)
