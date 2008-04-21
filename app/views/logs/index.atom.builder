atom_feed(:url => formatted_game_logs_url(@game, :atom)) do |feed|
  feed.title('Events for {game} at {account}'[:event_for_game_at_account, @game.name, current_account.name])
  feed.updated(@logs.first ? @logs.first.created_at : Time.now.utc)

  @logs.each do |log|
    feed.entry(log, :url => log_uri(log), :published => log.published_at) do |entry|
      entry.title(log.message)
      entry.content(log.published_at.to_s(:short), :type => 'html')
      entry.updated(log.published_at)

      entry.author do |author|
        author.name(find_user(log.user_id).name)
        author.email(find_user(log.user_id).email)
      end
    end
  end
end