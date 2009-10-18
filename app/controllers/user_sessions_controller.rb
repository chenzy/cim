class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save && !@user_session.user.suspended?
      flash[:notice] = "欢迎进入企业内部管理系统"
      if @user_session.user.login_count > 1 && @user_session.user.last_login_at?
        flash[:notice] << " 您最后一次登录日期是： " << @user_session.user.last_login_at.to_s(:mmddhhss)
      end
      redirect_back_or_default root_url
    else
      if @user_session.user && @user_session.user.awaits_approval?
        flash[:notice] = "您的账号还未审核通过"
      else
        flash[:warning] = "用户名或密码不正确"
      end
      redirect_to :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "退出成功"
    redirect_back_or_default new_user_session_url
  end
end
