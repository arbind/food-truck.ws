OAuth= require('oauth').OAuth
foodtruckws = TwitterConsumers.FoodTruckWS
oa = new OAuth "https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", foodtruckws.consumer.key, foodtruckws.consumer.secret, "1.0", foodtruckws.consumer.callback_url, "HMAC-SHA1"

update_access_token = (twitter_id, screen_name, oauth_access_token, oauth_access_token_secret) ->
  tid = (parseInt twitter_id)
  console.log "need to update #{screen_name}[#{twitter_id}]: #{oauth_access_token}[#{oauth_access_token_secret}]"
  skinTweetAPIAccounts = exports.appData.skinTweetAPIAccounts
  skinTweetAPIAccounts.findOne twitter_id: tid, (err, account) ->
    if err
      console.log 'findOne error:', err 
    else if not account
      console.log "#{screen_name}[#{twitter_id}] Not Found!"
    else
      console.log account
      oauth = account.oauth || {}
      oauth.twitter ||= {}
      oauth.twitter.foodtruckws ||= {}
      oauth.twitter.foodtruckws.access_token = oauth_access_token
      oauth.twitter.foodtruckws.access_token_secret = oauth_access_token_secret
      updates = screen_name: screen_name, oauth: oauth
      console.log "about to update: #{updates.toString()}"
      skinTweetAPIAccounts.update twitter_id: tid, $set: updates, (err, result) ->
        console.log 'update error', err if err
        console.log 'update with no error - looking it up'
        console.log "#{result}"
        skinTweetAPIAccounts.findOne twitter_id: tid, (er, acc) ->
          console.log 'looked up'
          console.log acc

exports.foodtruckws_login = (req, res) ->
  oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
    if error
      console.log(error)
      res.send("yeah no. didn't work.")
    else
      req.session.oauth = {}
      req.session.oauth.token = oauth_token
      console.log('oauth.token: ' + req.session.oauth.token)
      req.session.oauth.token_secret = oauth_token_secret
      console.log('oauth.token_secret: ' + req.session.oauth.token_secret)
      res.redirect('https://twitter.com/oauth/authenticate?oauth_token='+oauth_token)

exports.foodtruckws_callback = (req, res) ->
  if req.session.oauth
    oauth = req.session.oauth
    req.session.oauth.verifier = req.query.oauth_verifier
    oa.getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier, (error, oauth_access_token, oauth_access_token_secret, results) ->
      if error
        console.log error
        return res.send "Something Broke!"
      else
        req.session.oauth = {}
        twitter_id = results.user_id
        screen_name = results.screen_name
        update_access_token(twitter_id, screen_name, oauth_access_token, oauth_access_token_secret)
        res.redirect('/tweet-streamers')
  else
    res.send "you're not supposed to be here."
