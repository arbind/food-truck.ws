exports.index = (req, res) ->
  console.log 'showing tweet streamers'
  r = exports.appData.skinTweetAPIAccounts.find "is_tweet_streamer" : true
  r.toArray (err, items)->
    res.render 'tweet_streamers', title: 'Tweet Streamers', list: items 
