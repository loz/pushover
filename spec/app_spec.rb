require 'spec_helper'
require 'rack/test'

describe App do
  include Rack::Test::Methods

  let(:app) { subject }
  let(:user) { User.create :uid => 1234, :name => 'a_user'}

  def setup_session(session)
    Rack::Session::Abstract::SessionHash.stub(:new).and_return(session)
  end

  def setup_loggedin
    setup_session :userid => user.id
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
        setup_loggedin
        get '/'
      end

      it "does not render sign in" do
        last_response.body.should_not include "/auth/github"
      end

      it "renders create new endpoint" do
        last_response.body.should include "/new"
      end

      it "welcomes user by name" do
        last_response.body.should include "Welcome, a_user"
      end

      context "when the user has endpoints" do
        before :each do
          @endpoints = []
          2.times { @endpoints << user.endpoints.create }
          get '/'
        end

        it "lists links to each endpoint" do
          @endpoints.each do |e|
            last_response.body.should include "/endpoints/#{e.uid}/view"
          end
        end
      end

      context "when the user has no endpoints" do
        before :each do
          get '/'
        end

        it "suggests they create one" do
          last_response.body.should match /You have no endpoints, .*create one/
        end
      end
    end
  end

  describe '/new' do
    context "with no user" do
      it "redirects to /" do
        get '/new'
        last_response.should be_redirect
        last_response.location.should == 'http://example.org/'
      end
    end

    context "with a user" do
      before :each do
        setup_loggedin
      end

      it "creates a new endpoint for the user" do
        expect { get '/new'}.to change {Endpoint.count}.by(1)
      end

      it "redirects to the new endpoint view" do
        get '/new'
        last_response.should be_redirect
        endpoint = user.endpoints.last
        ref = endpoint.uid
        last_response.location.should == "http://example.org/endpoints/#{ref}/view"
      end
    end
  end

  describe '/endpoints/:uid' do
    before :each do
      @endpoint = user.endpoints.create
      @uid = @endpoint.uid
      @path = "/endpoints/#{@uid}"
    end

    it "responds with OK" do
      get @path
      last_response.should be_ok
    end

    it "saves message for GET requests" do
      path = "#{@path}?var1=value&var2=value"
      expect { get path, {}, {'HTTP_SOME' => 'header'} }.to change {Message.count }.by(1)
      message = @endpoint.messages.last
      message.should be
      message.method.should == 'get'
      message.query.should == 'var1=value&var2=value'
      message.headers['Some'].should == 'header'
    end

    it "saves message for POST requests" do
      expect { post @path, { :some => :body}, {'HTTP_ANOTHER_HEADER' => 'value'} }.to change {Message.count }.by(1)
      message = @endpoint.messages.last
      message.should be
      message.method.should == 'post'
      message.body.should == 'some=body'
      message.headers['Another-Header'].should == 'value'
    end

    it "saves message for PUT requests"
    it "saves message for DELETE requests"
  end

  describe '/endpoints/:uid/view' do
    context "with no user" do
      before :each do
        get '/endpoints/1234/view'
      end

      it "redirects to /" do
        last_response.should be_redirect
        last_response.location.should == 'http://example.org/'
      end
    end

    context "with a user" do
      before :each do
        setup_loggedin
        @e = user.endpoints.create
        get '/endpoints/%s/view' % @e.uid
      end

      it "shows the enpoint view page" do
        last_response.body.should include 'Messages to endpoint'
      end

      it "has link for message endpoint" do
        last_response.body.should include "http://example.org/endpoints/#{@e.uid}"
      end

      context "when the endpoint has no messages" do
        it "states no messages received" do
          last_response.body.should include "No messages have been received."
        end
      end

      context "when it has messages" do
        before :each do
          @e.messages.create :method => :post,
            :body => "something=value&another=too",
            :headers => {:some => :headers}
          @e.messages.create :method => :get,
            :query => "another=value&another=too",
            :headers => {:more => :heads}
          get '/endpoints/%s/view' % @e.uid
        end

        it "lists messages" do
          body_str = last_response.body.gsub("\n", '')
          body_str.should match /POST/
          body_str.should match /Headers.*some.*headers/
          body_str.should match /Body.*something=value&amp;another=too/
          body_str.should match /GET/
          body_str.should match /Headers.*more.*heads/
          body_str.should match /Query.*another=value&amp;another=too/
        end
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

    it "redirects to /" do
      last_response.should be_redirect
      last_response.location.should == 'http://example.org/'
    end

    context "when user already registered" do
      it "does not add user to the database" do
        expect { get '/auth/github/callback?code=foo' }.to_not change { User.count }
      end
    end
  end
end
