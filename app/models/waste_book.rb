class WasteBook < ActiveRecord::Base
  validates_presence_of :happen_time
  validates_presence_of :customer_id
  validates_presence_of :name, :message => "^Please specify waste_book name."
  validates_presence_of :money
  validates_numericality_of :money

  belongs_to :customer

  named_scope :only, lambda { |filters| { :conditions => [ "w_type in (?)", filters ] } }
  simple_column_search :name, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                      ; end
  def self.sort_by  ;  "waste_books.created_at DESC" ; end
end
