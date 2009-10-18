class CreateWarehouseLists < ActiveRecord::Migration
  def self.up
    create_table :warehouse_lists do |t|
      t.string :w_type
      t.integer :customer_id
      t.string :number
      t.datetime :happen_time
      t.decimal :total, :precision => 18, :scale => 2, :null => false
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :warehouse_lists
  end
end
