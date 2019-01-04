# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'

RuboCop::RakeTask.new

FoodCritic::Rake::LintTask.new do |f|
  f.options = { fail_tags: %w[any] }
end

RSpec::Core::RakeTask.new(:spec)

task default: %w[rubocop foodcritic spec]
