class CustomersController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  #after_filter  :update_recently_viewed, :only => :show

  # GET /customers
  # GET /customers.xml
  def index
    @customers = get_customers(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @campaigns }
    end
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])

    if params[:previous] =~ /(\d+)\z/
      @previous = Customer.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @customer
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
        
      if @customer.save 
        @customers = get_customers
        get_data_for_sidebar
        format.js
        format.html { redirect_to(@customer) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.html { redirect_to(@customer) }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy if @customer

    respond_to do |format|
      format.js   { respond_to_destroy(:ajax) }
      format.html { respond_to_destroy(:html) }        
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /accounts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @customers = get_customers(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @customers.to_xml }
    end
  end
                                                   
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_customer_type] = params[:c_type]
    @customers = get_customers(:page => 1)
    render :action => :index
  end

  def get_customers(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.preference[:customers_sort_by] || Customer.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.preference[:customers_per_page]
    }

    # Call :get_leads hook and return its output if any.
    customers = hook(:get_customers, self, :records => records, :pages => pages)
    return customers.last unless customers.empty?

    # Default processing if no :get_leads hooks are present.
    if session[:filter_by_customer_type]
      filtered = session[:filter_by_customer_type].split(",")
      current_query.blank? ? Customer.only(filtered) : Customer.only(filtered).search(current_query)
    else
      current_query.blank? ? Customer.all() : Customer.search(current_query)
    end.paginate(pages)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @customers = get_customers
      if @customers.blank?
        @customers = get_customers(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = "#{@customer.name} �Ѿ�ɾ��."
      redirect_to(customers_path)
    end
  end
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @customer_type_total = { :all => Customer.all().size() }
    @customer_type_total[:stock] = Customer.all(:conditions => [ "c_type=?", "stock" ]).size()
    @customer_type_total[:supply] = @customer_type_total[:all] - @customer_type_total[:stock]
  end
end
