namespace :tools do
  desc 'Synchronize all sorts of things, such as db, schema in models, etc.'
  task sync: ['db:migrate', 'annotate_models']

  namespace :fix do
    desc 'Update rankings'
    task rankings: :environment do
      Account.all.each do |account|
        account.games.each do |game|
          Match.reset_rankings(game)
        end
      end
    end
  end

  namespace :fake_data do
    desc 'Insert fake people'
    task people: :environment do
      names = [
        'Al Pine',
        'Barry Tone',
        'Bill Board',
        'Ed Cetera',
        'Gene Ohme',
        'Justin Case',
        'Norm Al',
        'Sal Uthe',
        'Tim Berr',
        'Wall Russ'
      ]
      names.each do |name|
        User.create(name: name, display_name: name.split(' ').first)
      end
    end

    desc 'Insert 500 fake games'
    task games: :environment do
      people = User.all

      500.times do |index|
        players = people.sort_by { rand }.slice(0...4)
        score = [10, rand(12) + 1]
        score[0] = score[1] + 2 if score[1] >= 9
        score = score.sort_by { rand }

        game = Match.new
        game.teams_from_params(
          [
            { score: score[0], members: [players[0].id, players[1].id] },
            { score: score[1], members: [players[2].id, players[3].id] }
          ]
        )
        game.played_at = (500 - index).hours.ago
        game.save

        puts "#{index + 1} games added..." if (index + 1) % 100 == 0
      end
    end

    desc 'Initialize database - RESET and insert fake data'
    task init: ['db:reset', 'tools:fake_data:people', 'tools:fake_data:games']
  end
end
