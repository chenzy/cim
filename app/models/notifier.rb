class Notifier < ActionMailer::Base
  
  #----------------------------------------------------------------------------
  def password_reset_instructions(user)
    subject       "企业内部管理系统: 密码重置操作指南"
    from          "czy0203@163.com"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_url => edit_password_url(user.perishable_token)
  end

end
