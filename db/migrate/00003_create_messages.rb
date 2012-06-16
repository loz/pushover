class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :endpoint
      t.string :method
      t.string :query
      t.text :body
      t.text :headers
    end
  end
end
