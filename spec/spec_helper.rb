# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'
require 'simplecov'
require 'simplecov-console'
require_relative '../libraries/helpers'

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.minimum_coverage(100)
SimpleCov.start
