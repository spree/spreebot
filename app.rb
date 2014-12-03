require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'
require 'active_support/core_ext/hash/indifferent_access'

class Spreebot < Sinatra::Base
  attr_reader :payload

  # before do
  #   @payload = JSON.parse(request.body.read).with_indifferent_access
  # end

  post "/" do
    "OK\n"
  end
end