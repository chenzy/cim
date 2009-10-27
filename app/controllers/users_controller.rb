class UsersController < ApplicationController
  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :only => [ :show ]
  before_filter :set_current_tab, :only => [ :show ] # Don't hightlight any tabs.
  before_filter :require_and_assign_user, :except => [ :new, :create, :show ]

  # GET /users
  # GET /users.xml                              HTML (not directly exposed yet)
  #----------------------------------------------------------------------------
  def index
    # not exposed
  end

  # GET /users/1
  # GET /users/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  def show
    @user = params[:id] ? User.find(params[:id]) : @current_user

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml                                                     HTML
  #----------------------------------------------------------------------------
  def new
    if can_signup?
      @user = User.new

      respond_to do |format|
        format.html # new.html.haml <-- signup form
        format.xml  { render :xml => @user }
      end
    else
      redirect_to login_path
    end
  end

  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    # <-- render edit.js.rjs
  end

  # POST /users
  # POST /users.xml                                                        HTML
  #----------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    if User.all().empty?
      @user.admin = true
    end
    if @user.save
      if Setting.user_signup == :needs_approval
        flash[:notice] = "您的账号已经创建，在等待系统管理员的审核"
        redirect_to login_url
      else
        flash[:notice] = "成功注册，欢迎进入企业内部管理系统"
        redirect_back_or_default profile_url
      end
    else
      render :action => :new
    end
  end

  # PUT /users/1
  # PUT /users/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.js
        format.xml { head :ok }
      else
        format.js
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml                HTML and AJAX (not directly exposed yet)
  #----------------------------------------------------------------------------
  def destroy
    # not exposed
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  def password
    # <-- render password.js.rjs
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password], true) || @user.crypted_password.blank?
      unless params[:user][:password].blank?
        @user.update_attributes(params[:user])
        flash[:notice] = "您的密码已经修改"
      else
        flash[:notice] = "您的密码还未修改"
      end
    else
      @user.errors.add(:current_password, "请正确输入您当前的密码")
    end
    # <-- render change_password.js.rjs
  end

  private
  #----------------------------------------------------------------------------
  def require_and_assign_user
    require_user
    @user = @current_user
  end

end
