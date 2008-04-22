module Factory
  def self.create_match(options = {})
    people = options.delete(:people) || Factory.create_people(4)
    team_scores = options.delete(:team_scores) || [10, 4]
    account = options.delete(:account) || self.create_account
    game = options.delete(:game) || self.create_game

    match = game.matches.build(options)
    match.score1 = team_scores[0]
    match.team1 = [people[0].id.to_s, people[1].id.to_s]
    
    match.score2 = team_scores[1]
    match.team2 = [people[2].id.to_s, people[3].id.to_s]
    
    match.account = account
    match.save!
    match
  end
  
  def self.create_people(amount)
    people = []
    (1..amount).each do |number|
      people << Factory.create_user(
        :login => "user#{number}",
        :email => "user#{number}@example.com",
        :name => "Person Personson #{number}",
        :display_name => "Person Personson #{number}")
    end
    people
  end
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => 'admin',
      :password => 'admin',
      :password_confirmation => 'admin',
      :email => 'admin@example.com',
      :time_zone => 'Copenhagen'
    }
    User.create! default_attributes.merge(attributes)
  end
  
  def self.create_game(attributes = {})
    default_attributes = {
      :name => 'Foosball'
    }
    Game.create! default_attributes.merge(attributes)
  end
  
  def self.create_account(attributes = {})
    default_attributes = {
      :name => 'Account',
      :domain => 'account',
      :time_zone => 'Copenhagen'
    }
    Account.create! default_attributes.merge(attributes)
  end
end