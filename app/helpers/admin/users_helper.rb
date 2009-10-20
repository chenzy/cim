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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module Admin::UsersHelper

  #----------------------------------------------------------------------------
  def link_to_suspend(user)
    link_to_remote("挂起", :method => :put, :url => suspend_admin_user_path(user))
  end

  #----------------------------------------------------------------------------
  def link_to_reactivate(user)
    name = user.awaits_approval? ? "审核!" : "恢复!"
    link_to_remote(name, :method => :put, :url => reactivate_admin_user_path(user))
  end

  #----------------------------------------------------------------------------
  def link_to_confirm(user)
    link_to_remote("删除?", :method => :get, :url => confirm_admin_user_path(user))
  end

  #----------------------------------------------------------------------------
  def link_to_delete(user)
    link_to_remote("是",
      :method => :delete,
      :url => admin_user_path(user),
      :before => visual_effect(:highlight, dom_id(user), :startcolor => "#ffe4e1")
    )
  end

end
