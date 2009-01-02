# -----------
# Account
# -----------
Factory.sequence :account_name do |n|
  "Account #{n}"
end

Factory.sequence :account_domain do |n|
  "account#{n}"
end

Factory.define(:account) do |a|
  a.name { Factory.next(:account_name) }
  a.domain { Factory.next(:account_domain) }
end

# -----------
# User
# -----------
Factory.sequence :user_login do |n|
  "user#{n}"
end

Factory.sequence :user_email do |n|
  "user#{n}@example.com"
end

Factory.define(:user) do |u|
  u.association :account
  u.login { Factory.next(:user_login) }
  u.email { Factory.next(:user_email) }
  u.password 'topsecret'
  u.password_confirmation 'topsecret'
  u.name 'Joe Smith'
  u.display_name 'Joe'
  u.time_zone 'Copenhagen'
end

# -----------
# Game
# -----------
Factory.sequence :game_name do |n|
  "Game #{n}"
end

Factory.define(:game) do |g|
  g.association :account
  g.name { Factory.next(:game_name) }
  g.team_size 2
end

# -----------
# Match
# -----------
Factory.define(:match) do |m|
  m.association :account
  m.association :game

  m.score1 10
  m.team1 { [Factory(:user).id.to_s, Factory(:user).id.to_s] }

  m.score2 4
  m.team2 { [Factory(:user).id.to_s, Factory(:user).id.to_s] }
end

# -----------
# Comment
# -----------
Factory.define(:comment) do |c|
  c.association :user
  c.association :match
  c.body 'A test comment'
end

