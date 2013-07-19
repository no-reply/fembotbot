
require 'chatterbot/dsl'
require 'redis'
require 'yaml'
require 'json'

conf = YAML.load_file('config.yml')
tags = {}

redis = Redis.new()

blklist = []
blklist = JSON.parse(redis.get('blacklist')) unless redis.get('blacklist').nil?
blacklist blklist

for response in conf['responses'].keys
  for hashtag in conf['responses'][response]
    tags[hashtag] = [] unless tags.include?(hashtag)
    tags[hashtag] << response
  end
end

# create a since_id if none exists.
# this keeps us from resending old tweets
# if the bot goes up on another system
if redis.get('since').nil?
  # searching #fembot is a hurried hack
  search('#fembot') do |tweet| 
    redis.set 'since', tweet.id
  end
end

since_id = redis.get('since') 

loop do
  begin
    for hashtag in tags.keys
      search(hashtag) do |tweet|
        redis.set tweet.from_user, [hashtag].to_json if redis.get(tweet.from_user).nil?
        reply "@#{tweet_user(tweet)} #{tags[hashtag][0]}", tweet unless JSON.parse(redis.get(tweet.from_user)).include?(hashtag)
        redis.set 'since', tweet.id
        user_tags = JSON.parse(redis.get(tweet.from_user)) << hashtag
        redis.set tweet.from_user, user_tags.to_json
        redis.incr(hashtag)
      end
    end

    replies do |tweet|
      if tweet.text.downcase.include?(conf['blacklist_text'])
        blklist << tweet.from_user
        redis.set 'blacklist', blklist.to_json
        blacklist blklist
      end
      reply "#USER# I'm a feminist robot!", tweet
    end
    sleep 90
  rescue Twitter::Error::TooManyRequests
    sleep 1000
  end
end
