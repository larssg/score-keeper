module GamesHelper
  def game_title(game)
    [
      game.teams.first.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - '),
      "(#{game.teams.first.score} - #{game.teams.last.score})",
      game.teams.last.memberships.collect{ |m| find_user(m.user_id).display_name }.join(' - ')
    ].join(' ')
  end
end
