# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  @@stylesheet_base_name = File.basename(Dir[File.join(RAILS_ROOT, 'public', 'stylesheets', 'base*.css')].first) rescue nil
  @@javascript_base_name = File.basename(Dir[File.join(RAILS_ROOT, 'public', 'javascripts', 'base*.js')].first) rescue nil

  def title(page_title, options = {})
    @page_title = page_title
    @page_title_options = options
  end

  def page_title
    title = 'Score Keeper'[]
    title << ': ' + @page_title unless @page_title.blank?
    title << ' - ' + h(current_account.name)
    title
  end

  def stylesheet_link_merged
    if RAILS_ENV == 'production'
      content_tag 'link', ' ', { :href => "/stylesheets/#{@@stylesheet_base_name}", :media => 'screen, projection', :rel => 'stylesheet', :type => 'text/css' }
    else
      stylesheet_link_tag 'lib/reset', 'lib/typography', 'lib/grid', 'lib/forms', 'screen', :media => 'screen, projection'
    end
  end

  def javascript_include_tag_merged
    if RAILS_ENV == 'production'
      content_tag 'script', ' ', { :src => "/javascripts/#{@@javascript_base_name}", :type => 'text/javascript' }
    else
      javascript_include_tag 'jquery-ui', 'jquery-fx', 'jquery.tablesorter', 'jrails', 'application'
    end
  end

  def user_area(&block)
    return unless logged_in?
    concat content_tag(:div, capture(&block), :class => 'authenticated'), block.binding
  end

  def account_admin_area(&block)
    return unless account_admin?
    concat content_tag(:div, capture(&block), :class => 'admin'), block.binding
  end

  def admin_area(&block)
    return unless admin?
    concat content_tag(:div, capture(&block), :class => 'admin'), block.binding
  end

  def account_admin?
    logged_in? && current_user.is_account_admin? || current_user.is_admin?
  end

  def admin?
    logged_in? && current_user.is_admin?
  end

  def user_link(game, user)
    link_to h(user.display_name), game_user_path(game, user), :class => 'user'
  end

  def user_link_full(game, user)
    link_to h(user.name), game_user_path(game, user), :class => 'user'
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

  def create_or_update_button(object)
    submit_tag (object.new_record? ? 'Create'[] : 'Update'[]), :disable_with => (object.new_record? ? 'Creating'[] : 'Updating'[]) + '&hellip;'
  end
end
