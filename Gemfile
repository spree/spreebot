source 'https://rubygems.org'

ruby '2.1.2'

gem 'sinatra'
gem 'httparty'
gem 'activesupport'

gem 'octokit', '~> 3.6.1'

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
