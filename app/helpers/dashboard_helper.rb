module DashboardHelper
  def matches_per_day_chart(matches_per_day)
    require 'google_chart'
    data = matches_per_day.reverse.collect { |day| day[1].to_i }
    GoogleChart::LineChart.new('230x120') do |lc|
      lc.data 'Matches per day'[], data, '77BBDD'
      lc.axis :y, :range => [0, data.max], :color => '000000', :font_size => 12, :alignment => :center
      lc.show_legend = false
      return lc.to_url
    end
  end
end