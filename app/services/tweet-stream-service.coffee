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
    for account, idx in @accounts # find the next account that hasnot been launched
      break unless account.twitterClient
    return unless account
    return if account.twitterClient
    # console.log idx
    @launchStream account 

  launchStream: (account) ->
    return if not account # null account
    return if account.stream # stream already bound

    oauth = account.oauth_config
    oauth.access_token_key = oauth.oauth_token
    oauth.access_token_secret = oauth.oauth_token_secret

    twitterClient = new Twitter oauth
    account.twitterClient = twitterClient
    twitterClient.streamer_screen_name = account.screen_name
    twitterClient.streamer_location = account.address
    console.log "launching stream for #{account.screen_name} - #{account.address}"
    @emitHomeTimelineTweets(twitterClient) # issue first call
    setInterval (=> @emitHomeTimelineTweets(twitterClient)), msPollFrequency # schedule polling of subsequent calls

    setTimeout (=> @launchNextStream()), 800

  emitHomeTimelineTweets: (twitterClient) ->
    params = count: 5 # max tweets to retrieve
    params.since_id = twitterClient.since_id if twitterClient.since_id # retrieve only tweets after this tweet id

    twitterClient.getHomeTimeline params, (err, tweets) => # https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
      @emitter.emit('error', err, twitterClient.streamer_screen_name, twitterClient.streamer_address) if err # emit error

      if !tweets or 0==tweets.length or (1==tweets.length and tweets[0].id == twitterClient.since_id) # last tweet sometimes comes through again (twitter bug?)
        console.log "#{twitterClient.streamer_screen_name}: no new tweets"
        return

      for tweetData in tweets
        tweetData.streamer = {screen_name: twitterClient.streamer_screen_name, location: twitterClient.streamer_location }
        tweet = new Tweet tweetData
        # tweet.save()
        @emitter.emit('tweet', tweet)
      twitterClient.since_id = tweets[0].id # mark the most recent tweet id, on the next poll we can retrieve new tweets since

module.exports = new TweetStreamService