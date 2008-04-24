module Factory
  def self.create_match(options = {})
    account = options.delete(:account) || Factory.create_account
    game = options.delete(:game) || Factory.create_game
    people = options.delete(:people) || Factory.create_people(4, :account => account)
    team_scores = options.delete(:team_scores) || [10, 4]

    match = game.matches.build(options)
    match.score1 = team_scores[0]
    match.team1 = [people[0].id.to_s, people[1].id.to_s]
    
    match.score2 = team_scores[1]
    match.team2 = [people[2].id.to_s, people[3].id.to_s]
    
    match.account = account
    match.save!
    match
  end
  
  def self.create_comment(options = {})
    match = options.delete(:match) || Factory.create_match
    user = options.delete(:user) || match.teams.first.memberships.first.user
    body = options.delete(:body) || 'A test comment.'
    
    match.comments.create(:match => match, :user => user, :body => body)
  end
  
  def self.create_people(amount, options = {})
    options[:account] ||= Factory.create_account
    
    people = []
    (1..amount).each do |number|
      people << Factory.create_user(
        :account => options[:account],
        :login => "user#{number}",
        :email => "user#{number}@example.com",
        :name => "Person Personson #{number}",
        :display_name => "Person Personson #{number}")
    end
    people
  end
  
  def self.create_user(attributes = {})
    attributes[:account] ||= Factory.create_account
    
    default_attributes = {
      :name => 'Administrator',
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
      :name => 'Foosball',
      :team_size => 2
    }
    default_attributes[:account] = Factory.create_account if attributes[:account].nil?
    Game.create! default_attributes.merge(attributes)
  end
  
  def self.create_account(attributes = {})
    count = 1
    while Account.find_by_domain("account#{count}")
      count += 1
    end
    
    default_attributes = {
      :name => 'Account',
      :domain => "account#{count}",
      :time_zone => 'Copenhagen'
    }
    Account.create! default_attributes.merge(attributes)
  end
end