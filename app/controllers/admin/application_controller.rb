class Admin::ApplicationController < ApplicationController
  layout "admin/application"
  before_filter :require_admin_user
  
  private
  #----------------------------------------------------------------------------
  def require_admin_user
    require_user
    if @current_user && !@current_user.admin?
      flash[:notice] = "You must be Administrator to access this page."
      redirect_to root_path
      false
    end
  end

  # Autocomplete handler for all admin controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = self.controller_name.classify.constantize.scoped(:limit => 10).search(@query)
    render :template => "common/auto_complete", :layout => nil
  end

end