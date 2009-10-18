module WasteBooksHelper
  def waste_book_type_checbox(type, count)
    checked = (session[:filter_by_waste_book_type] ? session[:filter_by_waste_book_type].split(",").include?(type.to_s) : count > 0)
    check_box_tag("w_type[]",type, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"w_type=" + $$("input[name='w_type[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end
end
