atom_feed(:url => formatted_games_url(:atom)) do |feed|
  feed.title('Games'[])
  feed.updated(@games.first ? @games.first.created_at : Time.now.utc)

  @games.each do |game|
    feed.entry(game) do |entry|
      entry.title(game.played_at.to_s :short)
      entry.content(game.title, :type => 'html')

      entry.author do |author|
        author.name(game.creator.name)
        author.email(game.creator.email)
      end
    end
  end
end