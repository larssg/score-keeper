atom_feed(:url => formatted_games_url(:atom)) do |feed|
  feed.title('Games'[])
  feed.updated(@games.first ? @games.first.created_at : Time.now.utc)

  @games.each do |game|
    feed.entry(game) do |entry|
      entry.title(game_title(game))
      entry.content(game.played_at.to_s(:short), :type => 'html')

      entry.author do |author|
        author.name(find_user(game.creator_id).name)
        author.email(find_user(game.creator_id).email)
      end
    end
  end
end