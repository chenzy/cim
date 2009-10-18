class CreateWasteBooks < ActiveRecord::Migration
  def self.up
    create_table :waste_books do |t|
      t.integer :customer_id
      t.datetime :happen_time
      t.string :w_type
      t.decimal :money, :precision => 18, :scale => 2, :null => false
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :waste_books
  end
end
