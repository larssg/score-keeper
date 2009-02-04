module MatchesHelper
  def match_title(match)
    [ match.teams.first.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - '),
      "(#{match.teams.first.score} - #{match.teams.last.score})",
      match.teams.last.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - ')
    ].join(' ')
  end

  def match_feed_url(game, options = {})
    formatted_game_matches_url(game, :atom, {:feed_token => current_user.feed_token}.merge(options))
  end

  def human_date(date)
    date = date.to_time
    return 'Today'[] if date.in_time_zone.to_date == Time.now.in_time_zone.to_date
    return 'Yesterday'[] if date.in_time_zone.to_date == 1.day.ago.in_time_zone.to_date
    I18n.l(date.to_date, :format => 'long')
  end
end
