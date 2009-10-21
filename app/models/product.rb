class Product < ActiveRecord::Base
  validates_presence_of :name, :message => "^Please specify product name."

  simple_column_search :name, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                      ; end
  def self.sort_by  ;  "products.created_at DESC" ; end

  def name_with_spec_with_unit
    "#{name}（#{spec}）（#{unit}）"
  end
end
