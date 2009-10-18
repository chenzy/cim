class CreateWarehouseListItems < ActiveRecord::Migration
  def self.up
    create_table :warehouse_list_items do |t|     
      t.integer :warehouse_list_id
      t.integer :product_id
      t.decimal :amount, :precision => 18, :scale => 2, :null => false
      t.decimal :unit_price, :precision => 18, :scale => 2, :null => false
      t.decimal :total, :precision => 18, :scale => 2, :null => false
      t.text :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :warehouse_list_items
  end
end
