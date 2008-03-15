module Factory
  def self.create_game(options = {})
    people = options[:people] || Factory.create_people(4)
    team_scores = options[:team_scores] || [10, 4]

    game = Match.new
    game.score1 = team_scores[0]
    game.user11 = people[0].id
    game.user12 = people[1].id
    
    game.score2 = team_scores[1]
    game.user21 = people[2].id
    game.user22 = people[3].id
    
    game.save!
    game
  end

  def self.create_user(attributes = {})
    default_attributes = {
      :name => 'Person Personson'
    }
    User.create! default_attributes.merge(attributes)
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
      :email => 'admin@example.com'
    }
    User.create! default_attributes.merge(attributes)
  end
end