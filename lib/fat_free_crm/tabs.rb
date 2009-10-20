# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM
  class Tabs
    cattr_accessor :main
    cattr_accessor :admin

    # Class methods.
    #----------------------------------------------------------------------------
    def self.main
      @@main =  { :active  => true,  :text => "首页",     :url  => { :controller  => "/"              } },
        { :active  => false, :text  => "仓库",     :url  => { :controller  => "warehouse_lists"      } },
        { :active  => false, :text  => "现金收支",         :url  => { :controller  => "waste_books"          } },
        { :active  => false, :text  => "客户",     :url  => { :controller  => "customers"      } },
        { :active  => false, :text  => "产品",         :url  => { :controller  => "products"          } } 
      @@main || reload!(:main)
    end

    def self.admin
      @@admin = { :active => true,  :text => "用户",         :url => { :controller => "admin/users"    } },
        { :active => true,  :text => "配置",      :url => { :controller => "admin/settings" } },
        { :active => true,  :text => "插件",       :url => { :controller => "admin/plugins"  } }
      @@admin || reload!(:admin)
    end

    # Make it possible to reload tabs (:main, :admin, or both).
    #----------------------------------------------------------------------------
    def self.reload!(main_or_admin = nil)
      return if ENV['RAILS_ENV'].nil? || !ActiveRecord::Base.connection.tables.include?("settings")
      case main_or_admin
      when :main  then @@main  = Setting[:tabs]
      when :admin then @@admin = Setting[:admin_tabs]
      when nil    then @@main  = Setting[:tabs]; @@admin = Setting[:admin_tabs]
      end
    end

  end
end