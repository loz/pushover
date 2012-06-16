require 'spec_helper'

describe Endpoint do
  context "when creating" do
    it "assigns a unique uid" do
      user = User.create
      a = described_class.create! :user => user
      b = described_class.create! :user => user
      a.uid.should_not be_nil
      a.uid.should_not == b.uid
    end
  end
end
