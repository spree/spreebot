require File.expand_path("../../spec_helper", __FILE__)

describe 'Spreebot' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "fail" do
    it "blows up" do
      fail
    end
  end

  context 'POST /issue' do
    pending 'should remove unauthorized labels'

    context 'for a new issue' do
      pending 'should add the unverified label'
    end
  end
end
