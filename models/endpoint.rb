require 'securerandom'

class Endpoint < ActiveRecord::Base
  belongs_to :user
  has_many :messages

  before_validation :generate_uid, :on => :create

  private

  def generate_uid
    self[:uid] = SecureRandom.hex(10).to_s
  end
end
