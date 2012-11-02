ModelBase = (require './model-base')
TweetStoreService = (require rootPath.services + 'tweet-store-service')

class Tweet extends ModelBase
  Service: TweetStoreService
  className: ()-> 'Tweet'

  text: ()-> (@get 'text')

  user: ()-> (@get 'user') || {}
  screen_name: ()-> (@user().screen_name)

  streamer: ()-> (@get 'streamer') || {}
  streamer_screen_name: ()-> (@streamer().screen_name)

module.exports = Tweet
