xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml.channel do
    xml.title 'Games'[]
    xml.link games_url
    xml.language('en-us')
    
    @games.each do |game|
      xml.item do
        xml.title game.title
        xml.description game.played_at.to_s(:short), :type => 'html'
        xml.pubDate(game.created_at.strftime('%a, %d %b %Y %H:%M:%S %z'))
        xml.link game_url(game)
        xml.guid game_url(game)
      end
    end
  end
end