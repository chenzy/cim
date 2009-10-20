class WarehouseListsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  after_filter  :update_recently_viewed, :only => :show
  before_filter :can_modify?, :except => [:index, :show]
  # GET /warehouse_lists
  # GET /warehouse_lists.xml
  def index
    @warehouse_lists = get_warehouse_lists(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @warehouse_lists }
    end
  end

  # GET /warehouse_lists/1
  # GET /warehouse_lists/1.xml
  def show
    @warehouse_list = WarehouseList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @warehouse_list }
    end
  end

  # GET /warehouse_lists/new
  # GET /warehouse_lists/new.xml
  def new
    @warehouse_list = WarehouseList.new
    @customers = Customer.all(:order => "name")
    @customer = Customer.new
    @products = Product.all

    3.times { @warehouse_list.warehouse_list_items.build }
    
    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @warehouse_list }
    end
  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /warehouse_lists/1/edit
  def edit
    @warehouse_list = WarehouseList.find(params[:id])
    @customers = Customer.all(:order => "name")
    @customer  = @warehouse_list.customer || Customer.new
    @products = Product.all

    if params[:previous] =~ /(\d+)\z/
      @previous = WarehouseList.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @warehouse_list
  end

  # POST /warehouse_lists
  # POST /warehouse_lists.xml
  def create
    @warehouse_list = WarehouseList.new(params[:warehouse_list])

    @customer = Customer.save_for_warehouse_list(params)
    @warehouse_list.customer_id = @customer.id

    respond_to do |format|
      if @warehouse_list.save
        @warehouse_lists = get_warehouse_lists
        get_data_for_sidebar
        format.js
        format.html { redirect_to(@warehouse_list) }
        format.xml  { render :xml => @warehouse_list, :status => :created, :location => @warehouse_list }
      else
        @customers = Customer.all(:order => "name")

        @products = Product.all 
        unless params[:customer][:id].blank?
          @customer = Customer.find(params[:customer][:id])
        else
          if request.referer =~ /\/customers\/(.+)$/
            @customer = Customer.find($1) # related customer
          else
            @acustomer = Customer.new
          end
        end
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @warehouse_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /warehouse_lists/1
  # PUT /warehouse_lists/1.xml
  def update
    @warehouse_list = WarehouseList.find(params[:id])

    @customer = Customer.save_for_warehouse_list(params)
    @warehouse_list.customer_id = @customer.id

    respond_to do |format|
      if @warehouse_list.update_attributes(params[:warehouse_list])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.html { redirect_to(@warehouse_list) }
        format.xml  { head :ok }
      else
        @customers = Customer.all(:order => "name")
        @products = Product.all
        if @warehouse_list.customer
          @customer = Customer.find(@warehouse_list.customer.id)
        else
          @customer = Customer.new
        end
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @warehouse_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /warehouse_lists/1
  # DELETE /warehouse_lists/1.xml
  def destroy
    @warehouse_list = WarehouseList.find(params[:id])
    @warehouse_list.destroy if @warehouse_list

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
    @warehouse_lists = get_warehouse_lists(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @warehouse_lists.to_xml }
    end
  end
                                                   
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_warehouse_list_type] = params[:w_type]
    @warehouse_lists = get_warehouse_lists(:page => 1)
    render :action => :index
  end

  def get_warehouse_lists(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.preference[:warehouse_lists_sort_by] || WarehouseList.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.preference[:warehouse_lists_per_page]
    }

    # Call :get_leads hook and return its output if any.
    warehouse_lists = hook(:get_warehouse_lists, self, :records => records, :pages => pages)
    return warehouse_lists.last unless warehouse_lists.empty?

    # Default processing if no :get_leads hooks are present.
    if session[:filter_by_warehouse_list_type]
      filtered = session[:filter_by_warehouse_list_type].split(",")
      current_query.blank? ? WarehouseList.only(filtered) : WarehouseList.only(filtered).search(current_query)
    else
      current_query.blank? ? WarehouseList.all() : WarehouseList.search(current_query)
    end.paginate(pages)
  end
  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @warehouse_lists = get_warehouse_lists
      if @warehouse_lists.blank?
        @warehouse_lists = get_warehouse_lists(:page => current_page - 1) if current_page > 1
        #render :action => :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = "#{@warehouse_list.name}已经删除"
      redirect_to(warehouse_lists_path)
    end
  end
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @warehouse_list_type_total = { :all => WarehouseList.all().size() }
    @warehouse_list_type_total[:in] = WarehouseList.all(:conditions => [ "w_type=?", "in" ]).size()
    @warehouse_list_type_total[:out] = @warehouse_list_type_total[:all] - @warehouse_list_type_total[:in]
  end
end
