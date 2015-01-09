require 'spec_helper'

describe Github do

  let(:client) { Github.new }

  context ".label_is_valid?" do

    it "returns false for empty string" do
      expect(client.label_is_valid?('')).to eql false
    end

    it "returns false for unsupported label" do
      expect(client.label_is_valid?('foobar')).to eql false
    end

    it "returns true for all labels in Github::VALID_LABELS" do
      Github::VALID_LABELS.each do |label|
        expect(client.label_is_valid?(label)).to eql true
      end
    end

    it "returns true for all labels in Github::EXPLANATION_LABELS" do
      Github::EXPLANATION_LABELS.each do |label|
        expect(client.label_is_valid?(label)).to eql true
      end
    end

  end
  context ".explanations" do
    it "reads the files from the explanations directory" do
      expect(client.explanations[:expected_behavior]).to eq File.read(File.join(File.dirname(__FILE__), '../explanations/expected_behavior.md'))
    end
  end
end
