socket = io.connect()
socket.on 'connect', ->
  #socket.emit 'set nickname', prompt 'What is your nickname?'
  socket.on 'tweet-stream-login', (username, location, err, data)->
    # ($ '#message').append "<div>#{username}: login from #{location}with #{data.friends_count} friends and #{data.followers_count} followers</div>"
  socket.on 'tweet', (username, location, data)->
    console.log data
    ($ 'body').trigger 'tweet', data

  socket.on 'ready', ->
    ($ '#status').html 'connected'
    # socket.emit 'msg', prompt 'What you got to say?'


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
      @collection.on 'add', @addTweet, @
      ($ 'body').bind 'tweet', (ev, data) => @collection.add new Tweet data
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
