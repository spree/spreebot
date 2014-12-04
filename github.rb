require 'octokit'

class Github

  VALID_LABELS = %w(unverified verified failing works_for_me steps version expected_behavior feature_request solved stalled reopened not_a_bug)
  CORE_USERS = %w(schof jdutil huoxito peterberkenbosch rlister)

  CI_FAILED_LABEL = 'failing'
  PR_OPEN_STATE = 'open'
  UNVERIFIED_ISSUE_LABEL = 'unverified'

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
    client.add_labels_to_an_issue(repo, issue_id, [UNVERIFIED_ISSUE_LABEL])
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

  # Reject a PR that is failing on the CI server
  # adds the label "failing" to the PR and closes it.
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param pull_request_id [Integer] The pullrequest number on that repository
  #
  def reject_failing_pull(repo, pull_request_id)
    client.close_pull_request(repo, pull_request_id)
    client.add_labels_to_an_issue(repo, pull_request_id, [CI_FAILED_LABEL])
  end

  # Reopens a PR that was closed before when it failed on the CI server.
  # removes the label 'failing' as well.
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param pull_request_id [Integer] The pullrequest number on that repository
  #
  def reopen_succesfull_pull(repo, pull_request_id)
    client.update_pull_request(repo, pull_request_id, nil, nil, PR_OPEN_STATE)
    client.remove_label(repo, issue_id, CI_FAILED_LABEL)
  end

  # Label an existing issue using the specified text
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue [Integer] The issue number on that repository
  # @param label [String] The label to be applied to the issue
  def create_issue_label(repo, issue, label)
    client.add_labels_to_an_issue(repo, issue, [label])
  end

  # Removes a label from the specified issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue [Integer] The issue number on that repository
  # @param label [String] The label to be removed from the issue
  def remove_issue_label(repo, issue, label)
    # GH will create an event for removing the label, even if it doesn't exist
    # so we should check for that first
    return if client.labels_for_issue(repo, issue).select do |l|
      l[:name] == label
    end.empty?

    client.remove_label(repo, issue, label)
  end
end
