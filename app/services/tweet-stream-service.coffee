{ EventEmitter }  = (require 'events')
Twitter       = (require 'ntwitter')

rateLimitWindowDuration = 15 # in minutes https://dev.twitter.com/docs/rate-limiting/1.1/limits
rateLimitRequestsPerWindow = 15
msPollFrequency = 1000*60*Math.floor(rateLimitRequestsPerWindow / rateLimitWindowDuration) # ms to wait for polling
msPollFrequency = msPollFrequency + 8800 # add a buffer of 8.8 seconds to make sure we don't poll too early

class TweetStreamService extends EventEmitter

  constructor: () ->
    @emitter = @

  load: (twitterAPIAccounts) ->
    @accounts = twitterAPIAccounts
    @launchNextStream()

  launchNextStream: () ->
    account = null
    for account, idx in @accounts
      break unless account.twitterClient
    return unless account
    return if account.twitterClient
    console.log idx
    @launchStream account 
    # @launchStream @accounts[7]

  launchStream: (account) ->
    return if not account # null account
    return if account.stream # stream already bound

    oauth = account.oauth_config
    oauth.access_token_key = oauth.oauth_token
    oauth.access_token_secret = oauth.oauth_token_secret

    twitterClient = new Twitter oauth
    account.twitterClient = twitterClient
    twitterClient.twitter_screen_name = account.screen_name
    twitterClient.twitter_address = account.address
    console.log "launching stream for #{account.screen_name} - #{account.address}"
    @emitHomeTimelineTweets(twitterClient) # issue first call
    setInterval (=> @emitHomeTimelineTweets(twitterClient)), msPollFrequency # schedule polling of subsequent calls

    setTimeout (=> @launchNextStream()), 800

  emitHomeTimelineTweets: (twitterClient) ->
    params = count: 5 # max tweets to retrieve
    params.since_id = twitterClient.since_id if twitterClient.since_id # retrieve only tweets after this tweet id

    twitterClient.getHomeTimeline params, (err, tweets) => # https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
      # console.log "#{twitterClient.twitter_screen_name}: error: #{err}" if err # emit error
      @emitter.emit('error', twitterClient.twitter_screen_name, twitterClient.twittter_address, err, err) if err # emit error
      if !tweets or 0==tweets.length or (1==tweets.length and tweets[0].id == twitterClient.since_id) # last tweet sometimes comes through again (twitter bug?)
        console.log "#{twitterClient.twitter_screen_name}: no new tweets"
        return

      for tweetData in tweets
        tweetData.streamer = {screen_name: twitterClient.twitter_screen_name }
        # t = new Tweet tweetData
        # console.log "[#{tweetData.id}]#{tweetData.user.screen_name}[#{tweetData.created_at}]: #{tweetData.text}"
        @emitter.emit('tweet', twitterClient.twitter_screen_name, twitterClient.twitter_address, tweetData)
      twitterClient.since_id = tweets[0].id

    # streamer.stream 'user', (stream)->
    #   account.stream = stream
    #   # console.log "#{account.name}: #{stream.toJSON()}"
    #   tweetStreamService.emit('connected', account.name, account.address)

    #   stream.on 'error', (err, code) ->
    #     console.log "!! Streaming Error! #{account.name} error=#{err} code=#{code}"
    #     tweetStreamService.emit('error', account.name, account.address, err, code)    

    #   stream.on 'data', (data)->
    #     tweetStreamService.emit('listening', account.name, account.address, data) unless account.listening
    #     account.listening = true
    #     data.tweet_id = data.id
    #     tweetStreamService.emit('tweet', account.name, account.address, data)

    #   stream.on 'limit', (data)->
    #     tweetStreamService.emit('limit', account.name, account.address, data)
    #   stream.on 'delete', (data)->
    #     tweetStreamService.emit('delete', account.name, account.address, data)
    #   stream.on 'scrub_geo', (data)->
    #     tweetStreamService.emit('scrub_geo', account.name, account.address, data)

    #   stream.on 'end', (response)->
    #     tweetStreamService.emit('disconnected', account.name, account.address, response)
    #     # handle connection closed
    #   stream.on 'destroy', (response)->
    #     tweetStreamService.emit('destroyed', account.name, account.address, response)
    #     # handle connection deleted

    #   wait = 10000
    #   util.delay wait, ->
    #     console.log "launching another stream after waiting for #{wait} ms!"
    #     tweetStreamService.launchNextStream() 


module.exports = new TweetStreamService