# frozen_string_literal: true
Factory.define(:match) do |m|
  m.association :account
  m.association :game

  m.score1 10
  m.team1 { [Factory(:user).id.to_s, Factory(:user).id.to_s] }

  m.score2 4
  m.team2 { [Factory(:user).id.to_s, Factory(:user).id.to_s] }
end
