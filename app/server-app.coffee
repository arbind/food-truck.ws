appEnvironment = (require '../config/application')

socketIO      = (require 'socket.io')
express       = (require 'express')
http          = (require 'http')
path          = (require 'path')
connectAssets = (require 'connect-assets')

routes        = (require './routes')
user          = (require './routes/user')

app = express()
app.use express.cookieParser()
app.use express.session secret: 'foodtrucko'
assetsPipeline = connectAssets src: 'app/assets'
css.root = 'stylesheets'
js.root = 'javascripts'

app.configure ->
  app.set 'port', process.env.PORT || process.env.VMC_APP_PORT || 8888
  app.set 'views', (__dirname + '/views')
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser('your secret here')
  # app.use express.session()
  app.use app.router
  app.use express.static(path.join(__dirname, 'public'))
  app.use assetsPipeline
  # app.use(require('stylus').middleware(__dirname + '/public'));

app.configure 'production', -> app.use express.errorHandler()
app.configure 'development', -> app.use (express.errorHandler dumpExceptions: true, showStack: true )

app.get ['/', '/index'], routes.index

app.get '/users', routes.user.list

app.get '/oauth/twitter/foodtruckws/login', routes.oauth_twitter.foodtruckws_login
app.get '/oauth/twitter/foodtruckws/callback', routes.oauth_twitter.foodtruckws_callback

app.get '/tweet-streamers', routes.tweet_streamers.index


appData.arg1 = 'Sample-Arg'
appData.skinTweetAPIAccounts = mongoDB.collection 'tweet_api_accounts'

r = appData.skinTweetAPIAccounts.find "is_tweet_streamer" : true
r.toArray (err, items)-> 
  appData.tweetStreamers = items
  TweetStreamService.load items

TweetStreamService.on 'Tweet', (tweet)->
  # console.log tweet.toJSON()

TweetStreamService.on 'error', (err, streamer_screen_name, streamer_location)->
  console.log "!! #{streamer_screen_name}[#{streamer_location}]: Unexpected Error!"
  console.log err

httpServer  = http.createServer app
io          = socketIO.listen httpServer

httpServer.listen (app.get 'port'), -> 
  console.log "Express server listening on port #{app.get 'port'}"

# Heroku doesn't yetallow use of WebSockets: setup long polling instead.
# https://devcenter.heroku.com/articles/using-socket-io-with-node-js-on-heroku
# https://github.com/LearnBoost/Socket.IO/wiki/Configuring-Socket.IO
io.configure ->
  (io.set "transports", ["xhr-polling"])
  (io.set "polling duration", 10)
  (io.set "log level", 2) 

io.sockets.on 'connection', (socket)->
  TweetStreamService.on 'Tweet', (tweet)-> 
    tweet.emitTo(socket) # emit any new tweets that stream in

  socket.on 'user-tweets', (screen_name) => # lookup tweets for user
    TweetStoreService.findUserTweets screen_name, (err, tweets) ->
      tweet.emitTo(socket) for tweet in tweets if tweets?

  socket.on 'streamer-tweets', (screen_name) => # lookup tweets for streamer
    TweetStoreService.findStreamerTweets screen_name, (err, tweets) ->
      tweet.emitTo(socket) for tweet in tweets if tweets?

  # socket.on 'set nickname', (name)->
  #   socket.set 'nickname', name, () ->
  #     socket.emit 'ready'

  # socket.on 'msg', ->
  #   socket.get 'nickname', (err, name)->
  #     console.log "chat message from #{name}"
