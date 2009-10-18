class ActivityObserver < ActiveRecord::Observer
  observe Customer, Product, WarehouseList, WasteBook
  @@tasks = {}
  @@leads = {}

  def after_create(subject)
    log_activity(subject, :created)
  end

  def before_update(subject)
=begin
    if subject.is_a?(Task)
      @@tasks[subject.id] = Task.find(subject.id).freeze
    elsif subject.is_a?(Lead)
      @@leads[subject.id] = Lead.find(subject.id).freeze
    end
=end
  end

  def after_update(subject)
=begin
    if subject.is_a?(Task)
      original = @@tasks.delete(subject.id)
      if original
        return log_activity(subject, :completed)   if subject.completed_at && original.completed_at.nil?
        return log_activity(subject, :reassigned)  if subject.assigned_to != original.assigned_to
        return log_activity(subject, :rescheduled) if subject.bucket != original.bucket
      end
    elsif subject.is_a?(Lead)
      original = @@leads.delete(subject.id)
      if original && original.status != "rejected" && subject.status == "rejected"
        return log_activity(subject, :rejected)
      end
    end
=end
    log_activity(subject, :updated)
  end

  def after_destroy(subject)
    log_activity(subject, :deleted)
  end

  private
  def log_activity(subject, action)
    current_user = User.current_user
    Activity.log(current_user, subject, action) if current_user
  end
end
