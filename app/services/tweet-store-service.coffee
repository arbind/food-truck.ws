ServiceBase = (require './service-base')

class TweetStoreService extends ServiceBase
  @logError = global.logError

  # call back errors
  @NO_TWEET_ID: new Error 'No Tweet ID!'
  @NO_SCREEN_NAME: new Error 'No Twitter Screen Name!'
  @NO_STREAMER: new Error 'No Twitter Screen Name for Streamer !'

  # redis time to live
  # @ttl = 3*60*60*24 # 3 days
  # @setTTL: (time_limit)-> TweetStoreService.ttl = time_limit if time_limit

  @MAX_USER_TWEETS = 10

  # redis keys
  @w = "w" # prefix for collection of all tweets
  @idKey:          (tweet_id)=> "t:#{tweet_id}"
  @tweetKey:          (tweet)=> @idKey tweet.id()
  @userKey:     (screen_name)=> "u:#{screen_name}"
  @streamerKey: (screen_name)=> "s:#{screen_name}"
  @allTweetsKey:           ()=> @w

  @tweetCount: (callback)=>
    redis.zcard @allTweetsKey(), callback

  @save: (tweet)=>
    return false unless tweet
    try 
      tweetKey = (@tweetKey tweet)
      score = 0 - Date.now()                                                      # score in reverse chronological order
      redis.set tweetKey, tweet.toJSON()                                          # save tweet by tweet id
      redis.zadd (@userKey tweet.screen_name()), score, tweet.id()                # save tweet id to user
      redis.zadd (@streamerKey tweet.streamer_screen_name()), score, tweet.id()   # save tweet id to streamer
      redis.zadd @allTweetsKey(), score, tweet.id()                               # save tweet id to all tweets
      (@_pruneTweets tweet.screen_name())                                         # prune tweets asynchronously
      true
    catch exception
      logError exception
      false

  @findTweet: (tweet_id, callback )=>
    unless tweet_id # check that args are given
      callback(@NO_TWEET_ID, null); return
    @_findTweetForKey (@idKey tweet_id), callback

  @findUserTweets: (screen_name, limit, callback )=>
    (callback = limit; limit = 10) if "function" is typeof limit # default limit=10 for user, assume last arg is the callback
    unless screen_name # check that args are given
      callback(@NO_SCREEN_NAME, null); return
    @_dereferenceTweetsForZKey (@userKey screen_name), limit, callback

  @findStreamerTweets: (streamer_screen_name, limit, callback )=>
    (callback = limit; limit = 100) if "function" is typeof limit # default limit=100 for streamer, assume last arg is the callback
    unless streamer_screen_name # check that args are given
      callback(@NO_STREAMER, null); return
    @_dereferenceTweetsForZKey (@streamerKey streamer_screen_name), limit, callback

  @findAllTweets: (limit, callback )=>
    (callback = limit; limit = 100) if "function" is typeof limit # default limit=100 for streamer, assume last arg is the callback
    @_dereferenceTweetsForZKey @allTweetsKey(), limit, callback

  @delete: (tweets...)=>
    return unless tweets
    for tweet in tweets
      try 
        tweetKey = (@tweetKey tweet)
        redis.del  tweetKey                                                   # remove tweet
        redis.zrem (@userKey tweet.screen_name()), tweet.id()                 # remove tweet ref from user
        redis.zrem (@streamerKey tweet.streamer_screen_name()), tweet.id()    # remove tweet ref from streamer
        redis.zrem @allTweetsKey(), tweet.id()                                # remove tweet ref from all tweets
      catch exception
        logError exception


  # sort of private methods

  # finders
  @_findTweetForKey: (key, callback )=>
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = @_tweetFromJSON(json_string)
      catch exception
        @logError 'TweetStoreService @_findTweetForKey: \n', exception
        err = exception
      finally
        (callback err, result)

  @_dereferenceTweetsForZKey: (zkey,limit, callback)=>
    @_findTweetRefsForZKey zkey, limit, (err, tweet_id_refs)=>
      if err # don't go further if there was an error
        (callback err, null); return

      unless tweet_id_refs and 0<tweet_id_refs.length #don't lookup refs unless we have at least 1
        (callback null, null); return

      tweetKeys  = ((@idKey tweet_id) for tweet_id in tweet_id_refs) # convert tweet_id into key a tweet key (t:tweet_id)
      redis.mget tweetKeys, (err, jsonArray)=>
        resultList = null
        try
          resultList = @_tweetsFromJSONArray jsonArray
        catch exception
          @logError 'TweetStoreService @findUserTweet: \n', exception
          err = exception
        finally
          (callback err, resultList)

  @_findTweetRefsForZKey: (zkey, limit, callback)=>
    end = limit # number to retrieve or 0 to get all
    end = 0 if limit < 0 # default to 0 (get all) if < 0
    end = end-1 #  [0.. (limit-1)] (to get limit) or [0..-1] (to get all)
    redis.zrange zkey, 0, end, callback

  # de-serialization
  @_tweetFromJSON: (json_string)=> # throws exception if json can not be parsed
    return null unless json_string
    new Tweet JSON.parse(json_string)

  @_tweetsFromJSONArray: (jsonArray)=>
    resultList = [];
    return resultList unless jsonArray
    (resultList.push (@_tweetFromJSON json_string) ) for json_string in jsonArray
    resultList

  @_pruneTweets: (screen_name) =>
    return unless screen_name
    @findUserTweets screen_name, 0, (err, tweetList)=>
      return unless tweetList
      numTweets = tweetList.length
      return if @MAX_USER_TWEETS > numTweets
      idx = @MAX_USER_TWEETS - 1
      tweetList[idx]?.delete() while idx++ < numTweets


module.exports = TweetStoreService