xml.person do
  xml.name @person.full_name
  @person.memberships.find(:all, :order => 'id DESC').each do |membership|
    xml.match do
      game = membership.team.game
      xml.time game.played_at.to_s :db
      xml.teams do
        game.teams.each do |team|
          xml.team do
            team.memberships.each do |game_membership|
              person = game_membership.person
              xml.player do
                xml.id person.id
                xml.full_name person.full_name
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