class WarehouseList < ActiveRecord::Base
  has_many  :warehouse_list_items, :dependent => :destroy
  accepts_nested_attributes_for :warehouse_list_items, :reject_if => lambda { |a| a.values.all?(&:blank?) }, :allow_destroy => true

  belongs_to :customer

  validates_presence_of :happen_time
  validates_presence_of :number
  validates_presence_of :customer_id
  validates_presence_of :total
  validates_numericality_of :total

  named_scope :only, lambda { |filters| { :conditions => [ "w_type in (?)", filters ] } }
  simple_column_search :number, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }
 
  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                      ; end 
  def self.sort_by  ;  "warehouse_lists.created_at DESC" ; end
end
