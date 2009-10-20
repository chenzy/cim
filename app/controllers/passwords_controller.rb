class PasswordsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  before_filter :require_no_user
  
  #----------------------------------------------------------------------------
  def new
    # <-- render new.html.haml
  end
  
  #----------------------------------------------------------------------------
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "密码重置的操作指南已经发送给你，请检查您的邮件。"
      redirect_to root_url
    else
      flash[:notice] = "该邮箱地址无法找到相对应的用户。"
      redirect_to :action => :new
    end
  end
  
  #----------------------------------------------------------------------------
  def edit
    # <-- render edit.html.haml
  end

  #----------------------------------------------------------------------------
  def update
    if empty_password?
      flash[:notice] = "请输入新密码。"
      render :action => :edit
    elsif @user.update_attributes(params[:user])
      flash[:notice] = "密码更改成功。"
      redirect_to profile_url
    else
      render :action => :edit
    end
  end

  #----------------------------------------------------------------------------
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = <<-EOS
        对不起, 我们找不到您的用户信息，请重新从你的邮件中复制粘贴到浏览器上 或者 重试一下重置密码的过程。
      EOS
      redirect_to root_url
    end
  end

  #----------------------------------------------------------------------------
  def empty_password?
    (params[:user][:password] == params[:user][:password_confirmation]) &&
    (params[:user][:password] =~ /^\s*$/)
  end
end
