require 'chatterbot/dsl'
require 'yaml'

conf = YAML.load_file('config.yml')
tags = {}

for response in conf['responses'].keys
  for hashtag in conf['responses'][response]
    tags[hashtag] = [] unless tags.include?(hashtag)
    tags[hashtag] << response
  end
end

for hashtag in tags.keys
  puts "#{hashtag}:  #{tags[hashtag][0]}"
  # search(hashtag) do |tweet|
  #   reply "@#{tweet_user(tweet)} #{tags[hashtag][0]}", tweet
  # end
end

replies do |tweet|
  reply "#USER# I'm a feminist robot!", tweet
end
