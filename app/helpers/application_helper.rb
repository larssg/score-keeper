# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    @page_title = page_title
  end
end