xml.user do
  xml.name @user.name
  @memberships.each do |membership|
    xml.match do
      match = membership.team.match
      xml.time match.played_at.to_s :db
      xml.teams do
        match.teams.each do |team|
          xml.team do
            team.memberships.each do |match_membership|
              user = match_membership.user
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