class WarehouseListItem < ActiveRecord::Base
  belongs_to :warehouse_list

  validates_presence_of :amount
  validates_presence_of :unit_price
  validates_presence_of :total
  validates_presence_of :product_id
end
