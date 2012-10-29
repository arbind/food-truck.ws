ModelBase = (require './model-base')
TweetService = (require rootPath.services + 'tweet-service')

class Tweet extends ModelBase
  Service: TweetService

  text: ()-> (@get 'text')

  user: ()-> (@get 'user') || {}
  screen_name: ()-> (@user().screen_name)

  streamer: ()-> (@get 'streamer') || {}
  streamer_screen_name: ()-> (@streamer().screen_name)

module.exports = Tweet
