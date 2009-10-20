class Admin::SettingsController < Admin::ApplicationController
  before_filter :set_current_tab, :only => [ :index ]

  # GET /admin/settings
  # GET /admin/settings.xml
  #----------------------------------------------------------------------------
  def index
    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => nil }
    end
  end
end
