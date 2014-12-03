require File.expand_path("../../spec_helper", __FILE__)

describe 'Spreebot' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'POST /issue' do
    pending 'should remove unauthorized labels'

    context 'for a new issue' do
      pending 'should add the unverified label'
    end

    it 'should pass' do
      true # fake test
    end

    it 'should not fail' do
      raise 'but it does!'
    end

  end
end