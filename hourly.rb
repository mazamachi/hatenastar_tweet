require 'rubygems'
require './tweet.rb'
require 'clockwork'
include Clockwork

every(1.hour, 'hourly_job', at: '**:00') do
	judge = false
	begin
		Tweet.new.hourly_tweet
	rescue
		unless judge
			judge = true
			retry
		end
	end
end
