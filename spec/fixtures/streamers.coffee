Tweet = (require rootPath.models + 'tweet')

materializeTweet = (streamerScreanName, screenName, location, text)->
  tweet_id = Util.uid(numerical:true)
  user_id = Util.uid(numerical:true)
  tweetData =
    id: tweet_id
    id_str: "#{tweet_id}"
    text: text
    created_at: Date.now() #+++ this should look like: 'Sun Oct 28 03:30:51 +0000 2012'
    streamer:
      screen_name: streamerScreanName
    user: 
       id: user_id
       id_str: "#{user_id}"
       screen_name: screenName
       location: location
       name: "#{screenName}-Name"
       description: "A very fine description of #{screenName}"
       url: 'http://#{screenName}.com'
       created_at: Date.now() #+++ this should look like: 'Sun Oct 28 03:30:51 +0000 2012'
       followers_count: Util.random(0x10000)
       friends_count: Util.random(0x1000)
       statuses_count: Util.random(0x10000)
       favourites_count: Util.random(0x10)
       # entities: { url: [Object] description: [Object] }
       # protected: false
       # listed_count: 363
       # utc_offset: -21600
       # time_zone: 'Central Time (US & Canada)'
       # geo_enabled: true
       # verified: false
       # lang: 'en'
       # contributors_enabled: false
       # is_translator: false
       # profile_background_color: 'C0DEED'
       # profile_background_image_url: 'http://a0.twimg.com/profile_background_images/289272663/imgres-2.jpeg'
       # profile_background_image_url_https: 'https://si0.twimg.com/profile_background_images/289272663/imgres-2.jpeg'
       # profile_background_tile: true
       # profile_image_url: 'http://a0.twimg.com/profile_images/2150810501/icon_normal.png'
       # profile_image_url_https: 'https://si0.twimg.com/profile_images/2150810501/icon_normal.png'
       # profile_link_color: 'BA1C3B'
       # profile_sidebar_border_color: 'C0DEED'
       # profile_sidebar_fill_color: 'DE9E74'
       # profile_text_color: '333333'
       # profile_use_background_image: true
       # default_profile: false
       # default_profile_image: false
       # following: true
       # follow_request_sent: null
       # notifications: null
    # geo: null
    # coordinates: null
    # place: null
    # contributors: null
    # retweet_count: 0
    # entities: { hashtags: [] urls: [ [Object] ] user_mentions: [] }
    # favorited: false
    # retweeted: false
    # possibly_sensitive: false }
    # source: 'web'
    # truncated: false
    # in_reply_to_status_id: null
    # in_reply_to_status_id_str: null
    # in_reply_to_user_id: null
    # in_reply_to_user_id_str: null
    # in_reply_to_screen_name: null
  new Tweet tweetData

screenNames = ['superman', 'batman', 'wonderWoman', 'aquaman', 'flash', 'greenLantern', 'spidy', ]
streamers =
  la: { superman: [], batman: [] }
  austin: { wonderWoman:[], aquaman: [], flash:[] }
  miami: { greenLantern:[], spidy:[] }

for streamer, tweeters of streamers
  for own screenName, tweets of tweeters
    for i in [0..10]
      location = "#{streamer}, USA"
      text = "A #{screenName}-#{i} tweet from #{streamer}"
      tweets.push (materializeTweet streamer, screenName, location, text)
      # console.log "#{i}:#{streamer}-#{screenName} [#{text}]"

module.exports = streamers
