module CustomersHelper
  def customer_type_checbox(type, count)
    checked = (session[:filter_by_customer_type] ? session[:filter_by_customer_type].split(",").include?(type.to_s) : count > 0)
    check_box_tag("c_type[]",type, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"c_type=" + $$("input[name='c_type[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end
end
