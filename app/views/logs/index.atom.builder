atom_feed(:url => log_feed_url(@game)) do |feed|
  feed.title("Events for #{@game.name} at #{current_account.name}")
  feed.updated(@logs.first ? @logs.first.created_at : Time.now.utc)

  @logs.each do |log|
    feed.entry(log, :url => log_uri(log), :published => log.published_at, :updated => log.published_at) do |entry|
      message = format_message(log.game_id, log.message)
      entry.title(strip_tags(message))
      
      content = [message, log.published_at.to_s(:short)].join('<br />')
      entry.content(content, :type => 'html')

      entry.author do |author|
        author.name(find_user(log.user_id).name)
        author.email(find_user(log.user_id).email)
      end
    end
  end
end