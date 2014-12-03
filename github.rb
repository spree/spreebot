require 'octokit'

class Github

  VALID_LABELS = %w(unverified verified failing works_for_me steps version expected_behavior feature_request solved stalled)
  CORE_USERS = %w(schof jdutil huoxito peterberkenbosch)

  def client
    @github_client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  end

  # Removes all invalid labels from the issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue_id [Integer] The issue number on that repository
  #
  def remove_invalid_labels(repo, issue_id)
    labels = client.labels_for_issue(repo, issue_id)
    labels.each do |label|
      unless VALID_LABELS.include?(label.name)
        client.remove_label(repo, issue_id, label.name)
        client.delete_label!(repo, label.name)
      end
    end
  end

  # Add the label 'unverified' to the specified issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue_id [Integer] The issue number on that repository
  #
  def mark_issue_unverified(repo, issue_id)
    client.add_labels_to_an_issue(repo, issue_id, ['unverified'])
  end


  # Closes an issue when comment is done by a user in the [CORE_USERS] and applies
  # the passed in label when it's in the [VALID_LABELS]
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue [Integer] The issue number on that repository
  # @param login [String] The login name for the user that commented
  # @param label [String] The label to be applied to the issue
  #
  def close_and_label_issue(repo, issue, login, label)
    if CORE_USERS.include?(login) && VALID_LABELS.include?(label)
      client.add_labels_to_an_issue(repo, issue, [label])
      client.close_issue(repo, issue)
    end
  end
end
