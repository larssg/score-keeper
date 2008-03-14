atom_feed(:url => formatted_matches_url(:atom)) do |feed|
  feed.title('Matches'[])
  feed.updated(@matches.first ? @matches.first.created_at : Time.now.utc)

  @matches.each do |match|
    feed.entry(match) do |entry|
      entry.title(match_title(match))
      entry.content(match.played_at.to_s(:short), :type => 'html')

      entry.author do |author|
        author.name(find_user(match.creator_id).name)
        author.email(find_user(match.creator_id).email)
      end
    end
  end
end