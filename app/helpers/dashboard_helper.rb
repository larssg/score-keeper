module DashboardHelper
  def matches_per_day_chart(matches_per_day)
    require 'google_chart'
    GoogleChart::LineChart.new('230x120') do |bc|
      bc.data "Matches per day"[], matches_per_day.reverse.collect { |day| day[1] }, '77BBDD'
      bc.show_legend = false
      return bc.to_url
    end
  end
end