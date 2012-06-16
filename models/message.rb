class Message < ActiveRecord::Base
  belongs_to :endpoint
  serialize :headers
end
