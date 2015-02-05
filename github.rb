require 'octokit'
require 'pony'

class Github

  VALID_LABELS = %w(unverified verified failing reopened address_feedback need_specs discussion security)
  CORE_USERS = %w(BDQ schof JDutil huoxito peterberkenbosch rlister bryanmtl gmacdougall cbrunsdon jhawthorn adammathys seantaylor Senjai futhr athal7 jordan-brough)
  EXPLANATION_LABELS = %w(expected_behavior feature_request not_a_bug stalled steps version works_for_me security)

  CI_FAILED_LABEL = 'failing'
  PR_OPEN_STATE = 'open'
  UNVERIFIED_ISSUE_LABEL = 'unverified'

  def client
    @github_client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  end

  def label_is_valid?(label)
    valid_labels = VALID_LABELS + EXPLANATION_LABELS
    valid_labels.include?(label)
  end

  # Reads all the md files from the `explanations` dir and will build
  # a hash where the label is the key and the file contents the value.
  #
  # @return [Hash] the explanation hash with labels as key
  def explanations
    paths = Dir.glob(File.join(File.dirname(__FILE__), "explanations/*.md"))

    explanation_hash = {}

    paths.each do |path|
      pn = Pathname.new(path)
      key = pn.basename(".*").to_s.to_sym
      explanation_hash[key] = pn.read
    end
    explanation_hash
  end


  # Removes all invalid labels from the issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue_id [Integer] The issue number on that repository
  #
  def remove_invalid_labels(repo, issue_id)
    labels = client.labels_for_issue(repo, issue_id)
    invalid_labels = []
    labels.each do |label|
      unless label_is_valid?(label.name)
        client.remove_label(repo, issue_id, label.name)
        client.delete_label!(repo, label.name)
        invalid_labels << label.name
      end
    end

    msg = "You attempted to add an unsupported label, we only use the following labels: #{VALID_LABELS.join(", ")}"
    client.add_comment(repo, issue_id, msg) unless invalid_labels.empty?
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
  # @param issue_id [Integer] The issue number on that repository
  # @param login [String] The login name for the user that commented
  # @param label [String] The label to be applied to the issue
  #
  def close_and_label_issue(repo, issue_id, login, label)

    add_comment_to_issue(repo, issue_id, "not_authorized") unless CORE_USERS.include?(login)

    if CORE_USERS.include?(login) && label_is_valid?(label)
      client.add_labels_to_an_issue(repo, issue_id, [label])
      client.close_issue(repo, issue_id)
      add_comment_to_issue(repo, issue_id, label) if EXPLANATION_LABELS.include?(label)
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
  # @param issue_id [Integer] The issue number on that repository
  # @param label [String] The label to be applied to the issue
  def create_issue_label(repo, issue_id, label)
    client.add_labels_to_an_issue(repo, issue_id, [label])
  end

  # Removes a label from the specified issue
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue_id [Integer] The issue number on that repository
  # @param label [String] The label to be removed from the issue
  def remove_issue_label(repo, issue_id, label)
    # GH will create an event for removing the label, even if it doesn't exist
    # so we should check for that first
    return if client.labels_for_issue(repo, issue_id).select do |l|
      l[:name] == label
    end.empty?

    client.remove_label(repo, issue_id, label)
  end

  # Add a comment to the issue if an entry exists in the explanations hash
  # with the value in that hash to explain the closing reason better.
  #
  # @param repo [String] The repository in "user/repo" format. ie 'spree/spree'
  # @param issue_id [Integer] The issue number on that repository
  # @param label [String] The label to be removed from the issue
  def add_comment_to_issue(repo, issue_id, label)
    if explanations.has_key?(label.to_sym)
      client.add_comment(repo, issue_id, explanations[label.to_sym])
    end
  end

  def redact_and_email_security_issue(repo, issue_id)
    issue = client.issue(repo, issue_id)
    title = issue.title
    body = issue.body
    submitted_by = issue.user
    client.update_issue(repo, issue_id, '[redacted]', explanations[:security])
    send_security_email(repo, issue_id, title, body, submitted_by)
  end

  def send_security_email(repo, issue_id, title, body, submitted_by)
    submitted_by_email = submitted_by.email
    Pony.mail to: 'security@spreecommerce.com',
      from: 'dontreply@spreecommerce.com',
      cc: submitted_by_email if submitted_by_email
      subject: "#{issue_id} - #{title} by #{submitted_by.login}",
      html_body: body,
      via: :smtp,
      via_options: {
        address: 'smtp.mandrillapp.com',
        port:    '587',
        user_name: ENV['MANDRILL_USERNAME'],
        password: ENV['MANDRILL_APIKEY'],
        authentication: :plain, # :plain, :login, :cram_md5, no auth by default
        domain: "spreebot.herokuapp.com"
      }
    end
  end

end
