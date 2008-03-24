atom_feed(:url => formatted_logs_url(:atom)) do |feed|
  feed.title('Events'[])
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