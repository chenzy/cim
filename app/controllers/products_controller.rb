class ProductsController < ApplicationController
  before_filter :require_user 
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  # GET /products
  # GET /products.xml
  def index
    @products = get_products(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])

    if params[:previous] =~ /(\d+)\z/
      @previous = Product.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @product
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
        
      if @product.save
        @products = get_products 
        format.js
        format.html { redirect_to(@product) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.js
        format.html { redirect_to(@product) }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

  # GET /accounts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @products = get_products(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @products.to_xml }
    end
  end


  def get_products(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.preference[:products_sort_by] || Product.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.preference[:products_per_page]
    }

    # Call :get_leads hook and return its output if any.
    products = hook(:get_products, self, :records => records, :pages => pages)
    return products.last unless products.empty?

    # Default processing if no :get_leads hooks are present.
    if session[:filter_by_product_type]
      filtered = session[:filter_by_product_type].split(",")
      current_query.blank? ? Product.only(filtered) : Product.only(filtered).search(current_query)
    else
      current_query.blank? ? Product.all() : Product.search(current_query)
    end.paginate(pages)
  end
 
end
