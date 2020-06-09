# frozen_string_literal: true
module DashboardHelper
  def position_icon(position)
    return '' if position.blank?

    now = position[:now].to_i
    before = position[:then].to_i

    if now < before
      return css_image_tag('arrow_up.png')
    elsif now == before
      return css_image_tag('arrow_right.png')
    elsif now > before
      return css_image_tag('arrow_down.png')
    end
    ''
  end
end