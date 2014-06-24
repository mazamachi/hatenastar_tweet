require 'rss'
require 'uri'

load("./hatenastar.rb")
class Hotentry
	attr_accessor :ranking, :user
	def initialize
		feed_url="http://b.hatena.ne.jp/hotentry?mode=rss"
		rss = RSS::Parser.parse(feed_url)
		ranking = []
		rss.items.each do |item|
			star = Hatenastar.new(item.link)
			scores = star.top10.to_a
			scores.each do |a|
				a << star.entry_url
			end
			ranking += scores
			ranking = ranking.sort  {|a, b| b[1] <=> a[1] }[0..9]
#			p ranking
		end
		@ranking = ranking
		#["(ブコメのURL)",スコア,"(entry_url)"]という配列の配列
	end
end
