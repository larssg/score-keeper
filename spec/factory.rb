module Factory
  def self.create_game(attributes = {})
    default_attributes = {
      :played_at => 5.minutes.ago
    }
    Game.create! default_attributes.merge(attributes)
  end
  
  def self.create_person(attributes = {})
    default_attributes = {
      :first_name => 'Person',
      :last_name => 'Personson'
    }
    Person.create! default_attributes.merge(attributes)
  end
  
  def self.create_people(amount)
    people = []
    (1..amount).each do |number|
      people << Factory.create_person(:last_name => "Personson #{amount}")
    end
    people
  end
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => 'admin',
      :password => 'admin',
      :password_confirmation => 'admin',
      :email => 'admin@example.com'
    }
    User.create! default_attributes.merge(attributes)
  end
  
  def self.create_default_game(options = {})
    people = options[:people] || Factory.create_people(4)
    game = options[:game] || Game.new
    team_scores = options[:team_scores] || [10, 4]
    
    team_one = game.teams.build(:score => team_scores[0])
    team_one.memberships.build(:person => people[0])
    team_one.memberships.build(:person => people[1])
    
    team_two = game.teams.build(:score => team_scores[1])
    team_two.memberships.build(:person => people[2])
    team_two.memberships.build(:person => people[3])
    
    game.save!
    game
  end
end