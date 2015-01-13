require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'
require 'active_support/core_ext/hash/indifferent_access'
require File.expand_path("../github", __FILE__)
require File.expand_path("../comment_helper", __FILE__)

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
    issue_number = issue['number'] if issue
    context = payload['context']
    commit = payload['commit']
    description = payload['description']
    event = env['HTTP_X_GITHUB_EVENT']

    if issue
      # remove any unofficial labels
      @gh.remove_invalid_labels(repo_name, issue_number)

      # add the unverified label if it's a new issue
      @gh.mark_issue_unverified(repo_name, issue_number) if action == 'opened'
    end

    if event == 'issue_comment' and action == 'created'
      comment_body = payload['comment']['body'].downcase
      comment_user = payload['comment']['user']['login']

      # check for rejection comments
      if(label = CommentHelper.parse_body(comment_body,"reject"))
        @gh.close_and_label_issue(repo_name, issue_number, comment_user, label)
      end

      # check for triage comments
      if(label = CommentHelper.parse_body(comment_body,"triage"))
        @gh.create_issue_label(repo_name, issue_number, label)
        @gh.remove_issue_label(repo_name, issue_number, 'unverified') if label == 'verified'
      end

      # check for close comments
      if(label = CommentHelper.parse_body(comment_body,"close"))
        @gh.close_and_label_issue(repo_name, issue_number, comment_user, label)
        @gh.remove_issue_label(repo_name, issue_number, 'unverified')
      end
    end

    if event == 'issues'
      # label the issue if it has been reopened
      @gh.create_issue_label(repo_name, issue_number, 'reopened') if action == 'reopened'
      # removed the 'reopened' label when closing (if applicable)
      @gh.remove_issue_label(repo_name, issue_number, 'reopened') if action == 'closed'
    end

    "OK\n"
  end
end
