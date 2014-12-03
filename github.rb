require 'octokit'

class Github

  VALID_LABELS = %w(unverified)
  CORE_USERS = %w(schof, jdutil, huoxito, peterberkenbosch)

  def client
    @github_client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  end

  # Removes all invalid labels from the issue
  #
  # @param [String, repo] The repository in "user/repo" format. ie 'spree/spree'
  # @param [Integer, issue] The issue number on that repository
  #
  def remove_invalid_labels(repo, issue)
    labels = client.labels_for_issue(repo, issue)
    labels.each do |label|
      client.remove_label(repo, 1, label.name) unless valid_labels.include?(label.name)
    end
  end
end
