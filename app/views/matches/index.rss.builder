xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml.channel do
    xml.title 'Matches'[]
    xml.link matches_url
    xml.language('en-us')
    
    @matches.each do |match|
      xml.item do
        xml.title match_title(match)
        xml.description match.played_at.to_s(:short), :type => 'html'
        xml.pubDate(match.created_at.strftime('%a, %d %b %Y %H:%M:%S %z'))
        xml.link match_url(match)
        xml.guid match_url(match)
      end
    end
  end
end