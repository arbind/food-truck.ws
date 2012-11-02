socket = io.connect()
socket.on 'connect', ->
  socket.on 'Tweet', (tweetData)-> ($ 'body').trigger 'Tweet', tweetData

window.loadUserTweets = (screen_name) -> socket.emit 'user-tweets', screen_name #'GGCvegas'
window.loadStreamerTweets = (screen_name) -> socket.emit 'streamer-tweets', screen_name # 'FTMUSTXAUS'

window.ClientApp = class ClientApp
  @views:{}
  @adapters: {}
  
# backbone
$ ->
  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };


  window.Tweet = Backbone.Model.extend()

  window.TweetStream = Backbone.Collection.extend
    model: Tweet

  window.TweetDisplay = Backbone.View.extend
    el: "#tweet-template"

    initialize: () ->
      @template = _.template @$el.html();

    render: () ->
      @el = @template @model.toJSON()

  window.TweetStreamDisplay = Backbone.View.extend
    initialize: () ->
      @collection = new TweetStream
      ($ 'body').bind 'Tweet', (ev, tweetData) => @collection.add new Tweet tweetData
      @collection.on 'add', @addTweet, @
      @render

    addTweet: (tweet) ->
      tweetDisplay = new TweetDisplay
        model: tweet
      x = tweetDisplay.render()
      $x = ($ x)
      ($ '#tweets').prepend $x
      $x.slideDown('slow')

    render: () ->
      #
  
  window.TweetStreamApp = class TweetStreamApp
    constructor: () ->
      @tweetStreamDisplay = new TweetStreamDisplay

  window.app = new TweetStreamApp
