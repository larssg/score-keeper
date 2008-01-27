xml.user do
  xml.name @user.name
  @memberships.each do |membership|
    xml.match do
      game = membership.team.game
      xml.time game.played_at.to_s :db
      xml.teams do
        game.teams.each do |team|
          xml.team do
            team.memberships.each do |game_membership|
              user = game_membership.user
              xml.player do
                xml.id user.id
                xml.name user.name
              end 
            end
            xml.score team.score
          end
        end
      end
      xml.ranking membership.current_ranking
    end
  end
end