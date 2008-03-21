module MatchesHelper
  def match_title(match)
    [
      match.teams.first.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - '),
      "(#{match.teams.first.score} - #{match.teams.last.score})",
      match.teams.last.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - ')
    ].join(' ')
  end
  
  def match_feed_url(options = {})
    formatted_matches_url(:atom, {:feed_token => current_user.feed_token}.merge(options))
  end
end
