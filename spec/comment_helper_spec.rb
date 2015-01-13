require 'spec_helper'

describe CommentHelper do

  it "parses the label from the complete body" do
    body = "This is sample data that will close:it"
    expect(CommentHelper.parse_body(body, "close")).to eql "it"
  end

  it "parses the commands from the complete body inline" do
    body = "This is sample data that will close:it when there is more text"
    expect(CommentHelper.parse_body(body, "close")).to eql "it"
  end

  it "parses the commands from the complete body with new lines" do
    body = "This is sample data that will \nclose:it"
    expect(CommentHelper.parse_body(body, "close")).to eql "it"
  end

  it "return nil when nothing found" do
    body = "This is sample data that will \nclose:it"
    expect(CommentHelper.parse_body(body, "triage")).to eql nil
  end

end
