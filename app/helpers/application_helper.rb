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
  
  def person_link(person)
    link_to person.display_name, person_path(person), :class => 'person'
  end
  
  def person_link_full(person)
    link_to person.full_name, person_path(person), :class => 'person'
  end
  
  def graph(url)
    out = ''
    out << '<div id="flashcontent"></div>'
    out << '<script type="text/javascript">'
    out << 'var so = new SWFObject("' + url_for('/flash/open-flash-chart.swf') + '", "chart", "100%", "450", "9", "#FFFFFF");'
    out << 'so.addVariable("width", "100%");'
    out << 'so.addVariable("height", "450");'
    out << 'so.addVariable("data", "' + url + '");'
    out << 'so.addParam("allowScriptAccess", "sameDomain");'
    out << 'so.write("flashcontent");'
    out << '</script>'
    out
  end
end