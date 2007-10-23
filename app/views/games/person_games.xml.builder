xml.person do
  xml.name @person.full_name
  @person.memberships.find(:all, :order => 'id DESC').each do |membership|
    xml.match do
      game = membership.team.game
      xml.time game.played_at.to_s :db
      xml.team1 do
        game.teams[0].memberships.each do |game_membership|
          xml.player game_membership.person.full_name
        end
        xml.score game.teams[0].score
      end
      xml.team2 do
        game.teams[1].memberships.each do |game_membership|
          xml.player game_membership.person.full_name
        end
        xml.score game.teams[1].score
      end
      xml.ranking membership.current_ranking
    end
  end
end