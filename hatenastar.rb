require 'open-uri'
require 'json'
require 'uri'
require 'time'
class Hatenastar
	attr_accessor :top10, :entry_url
	def initialize(entry_url)
		@top10 = get_scores(entry_url)
		@entry_url = entry_url
	end

	def starcount(permalinks)
		stars = { "yellow"=>1, "green"=>3, "red"=>6, "blue"=>10 }#各星色でのスコア
		scores = {}
		len = permalinks.length
		num = 100 #414 Request-URI Too Largeを防ぐために分割
		for i in 0..len/num
			decoded_link = "http://s.hatena.com/entry.json?uri="
			permalinks[num*i...num*(i+1)].each do |link| 
			#ブコメのパーマリンクの配列からJSONを取得するURIを作る。
				break	if link == nil
				decoded_link << URI.escape(link) <<"&uri="
			end
			decoded_link.slice!(-4,4) #末尾の"&uri="を削除
			bookmark_json = nil
			open(decoded_link) do |uri|
				bookmark_json = JSON.parse(uri.read)
			end
			bookmark_json["entries"].each do |entry| #各ブコメに対する操作
				scores[entry["uri"]] = 0
				scores[entry["uri"]] += entry["stars"].length #黄色スターの配列は0個以上
				if entry["colored_stars"]
					entry["colored_stars"].each do |colored_star|
						scores[entry["uri"]] += stars[colored_star["color"]]*(colored_star["stars"].length)
						#(色ごとのスコア*色付きスターの数)をscoreに足す
					end
				end
			end
		end
		scores
	end

	def get_permalinks(url) 
	#あるurlが与えられた時、その記事についたブコメのパーマリンクを配列として返す
		enrty_url = URI.escape(url)
		entry_json = nil
		open('http://b.hatena.ne.jp/entry/jsonlite/?url='+enrty_url) do |uri|
			entry_json = JSON.parse(uri.read)
		end
		permalinks = []
		entry_json["bookmarks"].each do |bookmark|
			time = Time.parse(bookmark["timestamp"])
			time_s = time.strftime("%Y%m%d")
			permalinks << ("http://b.hatena.ne.jp/" + bookmark["user"] + "/" + time_s + "#bookmark-" + entry_json["eid"])
		end
		permalinks
	end

	def get_scores(entry_url)
		a = get_permalinks(entry_url)
		scores = starcount(a)
		top10 = scores.sort  {|(k1, v1), (k2, v2)| v2 <=> v1 } 
		return top10[0..9] #ソートした結果の上位10個を返す
	end
end
