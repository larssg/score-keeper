# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    @page_title = page_title
  end
  
  def user_area(&block)
    if logged_in?
      concat content_tag(:div, capture(&block), :class => 'authenticated'), block.binding
    end
  end
  
  def admin_area(&block)
    if admin?
      concat content_tag(:div, capture(&block), :class => 'admin'), block.binding
    end
  end
  
  def admin?
    logged_in? && current_user.is_admin?
  end
end