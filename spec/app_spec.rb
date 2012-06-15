require 'spec_helper'
require 'rack/test'

describe App do
  include Rack::Test::Methods

  let(:app) { subject }

  describe '/' do
    before :each do
      get '/'
    end

    it "renders welcome page" do
      last_response.should be_ok
      last_response.body.should include "Welcome to Pushover"
    end

    context "when there is no user in session" do
      it "renders the sign in message" do
        last_response.body.should include "/auth/github"
      end
    end
  end
end
