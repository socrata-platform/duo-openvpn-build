# Encoding: UTF-8

source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'rubocop'
  gem 'foodcritic'
  gem 'rspec'
  gem 'chefspec'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'coveralls'
  gem 'fauxhai'
end

group :integration do
  gem 'serverspec'
end

group :build do
  gem 'fpm-cookery'
  gem 'packagecloud-ruby', '~> 1.0'
  gem 'chef', '>= 12.9'
  gem 'berkshelf'
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'kitchen-docker'
end
