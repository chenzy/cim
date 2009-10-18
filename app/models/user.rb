class User < ActiveRecord::Base
  attr_protected :admin, :suspended_at
   
  before_create  :check_if_needs_approval
  before_destroy :check_if_current_user, :check_if_has_related_assets

  has_many    :preferences, :dependent => :destroy

  named_scope :except, lambda { |user| { :conditions => "id != #{user.id}" } }
  default_scope :order => "id DESC" # Show newest users first.

  simple_column_search :login, :name, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  acts_as_authentic do |c|
    c.session_class = UserSession
    c.validates_uniqueness_of_login_field_options = { :message => "^This username has been already taken." }
    c.validates_uniqueness_of_email_field_options = { :message => "^There is another user with the same email." }
    c.validates_length_of_password_field_options  = { :minimum => 0, :allow_blank => true, :if => :require_password? }
    c.ignore_blank_passwords = true
  end

  # Store current user in the class so we could access it from the activity
  # observer without extra authentication query.
  cattr_accessor :current_user
  validates_presence_of :login, :message => "^Please specify the username."
  validates_presence_of :email,    :message => "^Please specify your email address."
  #----------------------------------------------------------------------------
  def suspended?
    self.suspended_at != nil
  end

  #----------------------------------------------------------------------------
  def awaits_approval?
    self.suspended? && self.login_count == 0 && Setting.user_signup == :needs_approval
  end
  #----------------------------------------------------------------------------
  def preference
    Preference.new(:user => self)
  end
  alias :pref :preference

  #----------------------------------------------------------------------------
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end


  private

  # Suspend newly created user if signup requires an approval.
  #----------------------------------------------------------------------------
  def check_if_needs_approval
    self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !self.admin
  end

  # Prevent current user from deleting herself.
  #----------------------------------------------------------------------------
  def check_if_current_user
    User.current_user && User.current_user != self
  end

  # Prevent deleting a user unless she has no artifacts left.
  #----------------------------------------------------------------------------
  def check_if_has_related_assets
    artifacts = %w(Account Campaign Lead Contact Opportunity Comment).inject(0) do |sum, asset|
      klass = asset.constantize
      sum += klass.assigned_to(self).count if asset != "Comment"
      sum += klass.created_by(self).count
    end
    artifacts == 0
  end
end
