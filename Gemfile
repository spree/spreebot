source 'https://rubygems.org'

ruby '2.0.0'

gem 'sinatra'
gem 'httparty'
gem 'active_support'

group :development do
  gem 'thin'
end

group :development, :test do
  gem 'pry-meta'
  gem 'rspec'
  gem 'rack-test'
end

group :production do
  gem 'unicorn'
end