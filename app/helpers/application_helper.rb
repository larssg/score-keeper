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
  
  def graph(url)
    out = ''
    out << '<div id="flashcontent" onmouseout="onrollout();"></div>'
    out << '<script type="text/javascript">'
    out << 'var so = new SWFObject("' + url_for('/flash/open-flash-chart.swf') + '", "chart", "720", "350", "9", "#FFFFFF");'
    out << 'so.addVariable("width", "720");'
    out << 'so.addVariable("height", "350");'
    out << 'so.addVariable("data", "' + url + '");'
    out << 'so.addParam("allowScriptAccess", "sameDomain");'
    out << 'so.write("flashcontent");'
    out << '</script>'
    out
  end
end