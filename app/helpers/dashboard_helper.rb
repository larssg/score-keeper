module DashboardHelper
  def log_link(log)
    if log.linked_model == 'Match'
      icon_link :game, h(log.message), match_path(log.linked_id)
    elsif log.linked_model == 'Comment'
      icon_link :comment, h(log.message), match_path(Comment.find(log.linked_id).match_id, :anchor => "c#{log.linked_id}")
    else
      h(log.message)
    end
  end
  
  def icon_link(icon, name, url)
    link_to image_tag("icons/#{icon}.png") + ' ' + name, url
  end

  def matches_per_day_chart(matches_per_day)
    require 'google_chart'
    data = matches_per_day.reverse.collect { |day| day[1].to_i }
    GoogleChart::LineChart.new('216x120') do |lc|
      lc.data 'Matches per day'[], data, '77BBDD'
      lc.axis :y, :range => [0, data.max], :color => '000000', :font_size => 12, :alignment => :center
      lc.show_legend = false
      return lc.to_url
    end
  end
end