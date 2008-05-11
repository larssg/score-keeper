namespace :scorekeeper do
  namespace :feed do
    desc "Fetch and parse news feed"
    task :fetch_and_parse => :environment do
      require 'feed-normalizer'
      feed = FeedNormalizer::FeedNormalizer.parse open('http://larssehested.com/taxonomy/term/1/0/feed')
      feed.items.each do |item|
        news_item = NewsItem.find_or_create_by_uid(item.id)
        news_item.name = item.title
        news_item.content = item.content
        news_item.url = item.urls.first
        news_item.posted_at = item.date_published
        news_item.save
      end
    end
  end
end