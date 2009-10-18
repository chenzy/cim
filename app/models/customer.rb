class Customer < ActiveRecord::Base
  validates_presence_of :name, :message => "^Please specify customer name."
  validates_uniqueness_of :name
  validates_presence_of :c_type
  
  has_many :waste_books

  named_scope :only, lambda { |filters| { :conditions => [ "c_type in (?)", filters ] } }
  simple_column_search :name, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                      ; end
  def self.sort_by  ;  "customers.created_at DESC" ; end

  def self.save_for_waste_book(params)
    unless params[:customer][:id].blank?
      @customer = Customer.find( params[:customer][:id])
    end
    unless params[:customer][:name].blank?
      @customer = Customer.new
      @customer.name = params[:customer][:name]    ;
      if(params[:waste_book][:w_type] == "income")
        @customer.c_type = "stock"
      else
        @customer.c_type = "supply"
      end
      @customer.save
    end
    @customer
  end

  def self.save_for_warehouse_list(params)
    unless params[:customer][:id].blank?
      @customer = Customer.find( params[:customer][:id])
    end
    unless params[:customer][:name].blank?
      @customer = Customer.new
      @customer.name = params[:customer][:name]    ;
      if(params[:warehouse_list][:w_type] == "income")
        @customer.c_type = "stock"
      else
        @customer.c_type = "supply"
      end
      @customer.save
    end
    @customer
  end
end
