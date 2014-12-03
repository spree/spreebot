require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'
require 'active_support/core_ext/hash/indifferent_access'
require File.expand_path("../github", __FILE__)

class Spreebot < Sinatra::Base
  attr_reader :payload

  before do
    @payload = JSON.parse(request.body.read).with_indifferent_access
    @gh = Github.new
  end

  post "/github" do
    content_type :json

    repo = payload['repository']
    repo_name = repo['full_name']
    action = payload['action']
    issue = payload['issue']
    issue_number = issue['number']

    if issue
      # remove any unofficial labels
      @gh.remove_invalid_labels(repo_name, issue_number)

      # add the unverified label if it's a new issue
      @gh.mark_issue_unverified(repo_name, issue_number) if action == 'opened'
    end

    "OK\n"
  end
end