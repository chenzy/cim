class WasteBooksController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  # GET /waste_books
  # GET /waste_books.xml
  def index
    @waste_books = get_waste_books(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @waste_books }
    end
  end

  # GET /waste_books/1
  # GET /waste_books/1.xml
  def show
    @waste_book = WasteBook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @waste_book }
    end
  end

  # GET /waste_books/new
  # GET /waste_books/new.xml
  def new
    @waste_book = WasteBook.new
    @customers = Customer.all(:order => "name")
    @customer = Customer.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @waste_book }
    end
  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /waste_books/1/edit
  def edit
    @waste_book = WasteBook.find(params[:id])
    @customers = Customer.all(:order => "name")
    @customer  = @waste_book.customer || Customer.new


    if params[:previous] =~ /(\d+)\z/
      @previous = WasteBook.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @waste_book
  end

  # POST /waste_books
  # POST /waste_books.xml
  def create
    @waste_book = WasteBook.new(params[:waste_book])

    @customer = Customer.save_for_waste_book(params)
    @waste_book.customer_id = @customer.id

    respond_to do |format|
      if @waste_book.save
        @waste_books = get_waste_books
        get_data_for_sidebar
        format.js
        format.html { redirect_to(@waste_book) }
        format.xml  { render :xml => @waste_book, :status => :created, :location => @waste_book }
      else
        @customers = Customer.all(:order => "name")
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
        format.xml  { render :xml => @waste_book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /waste_books/1
  # PUT /waste_books/1.xml
  def update
    @waste_book = WasteBook.find(params[:id])
    @customer =Customer.save_for_waste_book(params)
    @waste_book.customer_id =  @customer.id

    respond_to do |format|
      if @waste_book.update_attributes(params[:waste_book])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.html { redirect_to(@waste_book) }
        format.xml  { head :ok }
      else
        @customers = Customer.all(:order => "name")
        if @waste_book.customer
          @customer = Customer.find(@waste_book.customer.id)
        else
          @customer = Customer.new
        end
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @waste_book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /waste_books/1
  # DELETE /waste_books/1.xml
  def destroy
    @waste_book = WasteBook.find(params[:id])
    @waste_book.destroy if @waste_book

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
    @waste_books = get_waste_books(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @waste_books.to_xml }
    end
  end
                                                   
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_waste_book_type] = params[:w_type]
    @waste_books = get_waste_books(:page => 1)
    render :action => :index
  end

  def get_waste_books(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.preference[:waste_books_sort_by] || WasteBook.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.preference[:waste_books_per_page]
    }

    # Call :get_leads hook and return its output if any.
    waste_books = hook(:get_waste_books, self, :records => records, :pages => pages)
    return waste_books.last unless waste_books.empty?

    # Default processing if no :get_leads hooks are present.
    if session[:filter_by_waste_book_type]
      filtered = session[:filter_by_waste_book_type].split(",")
      current_query.blank? ? WasteBook.only(filtered) : WasteBook.only(filtered).search(current_query)
    else
      current_query.blank? ? WasteBook.all() : WasteBook.search(current_query)
    end.paginate(pages)
  end
  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @waste_books = get_waste_books
      if @waste_books.blank?
        @waste_books = get_waste_books(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = "#{@waste_book.name} �Ѿ�ɾ��."
      redirect_to(waste_books_path)
    end
  end
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @waste_book_type_total = { :all => WasteBook.all().size() }
    @waste_book_type_total[:income] = WasteBook.all(:conditions => [ "w_type=?", "income" ]).size()
    @waste_book_type_total[:outgo] = @waste_book_type_total[:all] - @waste_book_type_total[:income]
  end
end
