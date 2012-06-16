class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.references :user
      t.string :uid
    end
  end
end
