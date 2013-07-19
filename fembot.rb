require 'chatterbot/dsl'
require 'yaml'

conf = YAML.load_file('config.yml')

for hashtag in conf['hashtags']
  puts hashtag
  # search("'surely you must be joking'") do |tweet|
  #   reply "@#{tweet_user(tweet)} I am serious, and don't call me Shirley!", tweet
  # end
end

replies do |tweet|
   reply "#USER# I'm a feminist robot!", tweet
end
