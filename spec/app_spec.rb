require 'spec_helper'
require 'rack/test'

describe App do
  include Rack::Test::Methods

  let(:app) { subject }

  def setup_session(session)
    Rack::Session::Abstract::SessionHash.stub(:new).and_return(session)
  end

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

    context "when there is a user in the session" do
      before :each do
        @user = User.create :uid => 1234, :name => 'a_user'
        setup_session :userid => @user.id
        get '/'
      end

      it "does not render sign in" do
        last_response.body.should_not include "/auth/github"
      end
    end
  end

  describe '/auth/github/callback' do
    before :each do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:github, {
        :uid => 1234,
        :info => {
          :nickname => 'github_user'
        }
      })
      get '/auth/github/callback?code=foo'
    end

    it "adds the user to the database" do
      user = User.last
      user.uid.should == '1234'
      user.name.should == 'github_user'
    end

    it "sets userid into the session" do
      last_request.session[:userid].should == User.last.id
    end

    context "when user already registered" do
      it "does not add user to the database" do
        expect { get '/auth/github/callback?code=foo' }.to_not change { User.count }
      end
    end
  end
end
