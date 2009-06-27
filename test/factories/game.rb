Factory.sequence :game_name do |n|
  "Game #{n}"
end

Factory.define(:game) do |g|
  g.association :account
  g.name { Factory.next(:game_name) }
  g.team_size 2
end
