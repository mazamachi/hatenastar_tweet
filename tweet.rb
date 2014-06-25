require 'rubygems'
require 'twitter'
require 'bitly'
load("./hotentry_star.rb")  

class Tweet
  attr_accessor :tweets
  def initialize
    @cli = Twitter::REST::Client.new do |config|
      config.consumer_key       = '******************************'
      config.consumer_secret    = '******************************'
      config.access_token        = '******************************'
      config.access_token_secret = '******************************'
    end
    @tweets = make_tweets
  end
  
  def get_short_url(page_url) 
    Bitly.use_api_version_3 
    bitly = Bitly.new('************', '************************************')
    bitly.shorten(page_url).short_url
  end 

  def get_comment(user,url)
    enrty_url = URI.escape(url)
    entry_json = nil
    open('http://b.hatena.ne.jp/entry/jsonlite/?url='+enrty_url) do |uri|
      entry_json = JSON.parse(uri.read)
    end
    entry_json["bookmarks"].each do |bookmark|
      if bookmark["user"] == user
        return bookmark["comment"]
      end
    end
  end

  def get_infos
    ranking = Hotentry.new.ranking
    infos = {}
    num = 1
    ranking.each do |ar|
      infos[num] = {}
      infos[num][:user] = ar[0].match(%r{http://b.hatena.ne.jp/(.+)/})[1]
      infos[num][:score] = ar[1]
      infos[num][:url] = ar[2]
      infos[num][:comment] = get_comment(infos[num][:user],ar[2])
      num += 1
    end
    infos
  end

  def make_tweets
    tweets = []
    hour = Time.now.hour
    self.get_infos.each do |num,hash|
       tweet = "#{hour}時の#{num}位(#{hash[:score]}pts)#{hash[:user]}:#{hash[:comment]}"
      shorten = get_short_url(hash[:url])
      if tweet.length+shorten.length+1 <= 140
        tweet = tweet[0...(140-(shorten.length+1))] 
      else  #"…… "の分
        tweet = tweet[0...(140-(shorten.length+5))] 
        tweet << "……"
      end
      tweet << " " << shorten
      tweets << tweet
    end
    tweets
  end

  def hourly_tweet
    Tweet.new.tweets.reverse.each do |tweet| #10位からツイートしたいのでreverse
      update(tweet)
    end
  end

  def test
    t = Time.now.to_s
    update(t)
  end
  
  private
  def update(tweet)
    return nil unless tweet
    begin
      @cli.update(tweet.chomp)
    rescue => ex
      nil
    end
  end
end