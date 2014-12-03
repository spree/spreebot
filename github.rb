require 'octokit'

class Github

  VALID_LABELS = %w(unverified, verified, failing, works_for_me, steps, version, expected_behavior, feature_request, solved, stalled)
  CORE_USERS = %w(schof jdutil huoxito peterberkenbosch)

  def client
    @github_client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  end

  # Removes all invalid labels from the issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue [Integer] The issue number on that repository
  #
  def remove_invalid_labels(repo, issue)
    labels = client.labels_for_issue(repo, issue)
    labels.each do |label|
      unless VALID_LABELS.include?(label.name) do
        client.remove_label(repo, 1, label.name)
        client.delete_label!(repo, label.name)
      end
    end
  end

  # Add the label 'unverified' to the specified issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue [Integer] The issue number on that repository
  #
  def mark_issue_unverified(repo, issue)
    client.add_labels_to_an_issue(repo, issue, ['unverified'])
  end

end
