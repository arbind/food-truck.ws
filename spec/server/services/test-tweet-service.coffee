require (process.cwd() + '/config/application')

streamers = fixtureFor 'streamers'

uValue = (tweet)-> ("#{tweet.id()}-#{tweet.text()}")

showTweet = (tweet)-> 
  p "tweet.screenName(): #{tweet.text()}"

showFixtureTweets = ->
  console.log '--- Streamers ----'
  for streamer,tweeters of streamers
    for tweets,tweets of tweeters
      console.log tweet for tweet in tweets

deleteFixtureTweets = ->
  for streamer,tweeters of streamers
    for tweets,tweets of tweeters
      tweet.delete() for tweet in tweets

describe 'TweetStoreService', ->
  # setup test variables
  TweetStoreService.MAX_USER_TWEETS = 5

  @superman0 = streamers.la.superman[0] # tweet from LA - superman
  @superman1 = streamers.la.superman[1] # tweet from LA
  @superman2 = streamers.la.superman[2] # tweet from LA
  @superman3 = streamers.la.superman[3] # tweet from LA
  @superman4 = streamers.la.superman[4] # tweet from LA - superman
  @superman5 = streamers.la.superman[5] # tweet from LA
  @superman6 = streamers.la.superman[6] # tweet from LA
  @superman7 = streamers.la.superman[7] # tweet from LA
  @superman8 = streamers.la.superman[8] # tweet from LA
  @superman9 = streamers.la.superman[9] # tweet from LA
  @batman0 = streamers.la.batman[0]     # tweet from LA - batman
  @batman1 = streamers.la.batman[1]     # tweet from LA
  @batman2 = streamers.la.batman[2]     # tweet from LA
  @batman3 = streamers.la.batman[3]     # tweet from LA
  @flash0 = streamers.austin.flash[0]   # tweet from Austin - flash
  @flash1 = streamers.austin.flash[1]   # tweet from Austin
  @flash2 = streamers.austin.flash[2]   # tweet from Austin
  @flash3 = streamers.austin.flash[3]   # tweet from Austin

  before (done)=> ensureTestEnvironment(done)

  after (done)=> # clean up if necessary
    redis.keys '*', (err, keys)=>
      console.warn "!! Deleting #{keys.length} keys were leaked." if keys.length
      redis.del key for key, idx in keys
      done()

  describe 'initial state', =>
    before (done)=> # save a tweet  to an empty db
      should.exist @superman0 # make sure we have a new object that can be saved
      TweetStoreService.findTweet @superman0.id(), (err, nada)-> # make sure the new object is not already in db
        should.not.exist err, 'err'
        should.not.exist nada, 'nada'
      done()

    it '(tweetCount) starts at 0', (done)=>
      TweetStoreService.tweetCount (err, count)=>
        (expect count).to.equal 0
        done()

    it 'database is empty', (done)=>
      redis.keys '*', (err, keys)=>
        keys.should.have.length 0
        done()

  describe 'save a few tweets from la (superman and batman) and austin (flash)', =>
    # save 12 tweets - in this order:
    it '(save @superman0)', (done)=> @superman0.save().should.equal true; Util.aMoment(done)
    it '(save @batman0)',   (done)=>   @batman0.save().should.equal true; Util.aMoment(done)
    it '(save @flash0)',    (done)=>    @flash0.save().should.equal true; Util.aMoment(done)
    it '(save @batman1)',   (done)=>   @batman1.save().should.equal true; Util.aMoment(done)
    it '(save @batman2)',   (done)=>   @batman2.save().should.equal true; Util.aMoment(done)
    it '(save @flash1)',    (done)=>    @flash1.save().should.equal true; Util.aMoment(done)
    it '(save @batman3)',   (done)=>   @batman3.save().should.equal true; Util.aMoment(done)
    it '(save @flash2)',    (done)=>    @flash2.save().should.equal true; Util.aMoment(done)
    it '(save @superman1)', (done)=> @superman1.save().should.equal true; Util.aMoment(done)
    it '(save @superman2)', (done)=> @superman2.save().should.equal true; Util.aMoment(done)
    it '(save @flash3)',    (done)=>    @flash3.save().should.equal true; Util.aMoment(done)
    it '(save @superman3)', (done)=> @superman3.save().should.equal true; Util.aMoment(done)

    it '.tweetCount = 12', (done)=>
      TweetStoreService.tweetCount (err, count)=>
        (expect count).to.equal 12
        done()

  describe 'find tweets: most recent tweets on top', =>
    it '(findTweet superman2)', (done)=>
      TweetStoreService.findTweet @superman2.id(), (err, twt)=>
        should.not.exist err, 'err'
        should.exist twt, 'tweet'
        twt.id().should.equal @superman2.id()
        twt.text().should.equal @superman2.text()
        done()

    it "(findUserTweets superman) - get all of superman's tweets", (done)=>
      TweetStoreService.findUserTweets @superman0.screen_name(), (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 4
        # tweets should come out in reverse order
        # check the text for the top one
        twtList[0].text().should.equal @superman3.text();
        #check ids fo the rest

        (uValue twtList[0]).should.equal (uValue superman3)
        (uValue twtList[1]).should.equal (uValue superman2)
        (uValue twtList[2]).should.equal (uValue superman1)
        (uValue twtList[3]).should.equal (uValue superman0)
        done()

    it "(findUserTweets limit2, superman) - get 2 most recent tweets from superman", (done)=>
      TweetStoreService.findUserTweets @superman0.screen_name(), 2, (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 2
        # tweets should come out in reverse order
        (uValue twtList[0]).should.equal (uValue @superman3)
        (uValue twtList[1]).should.equal (uValue @superman2)
        done()

    it '(findStreamerTweets la) find tweets from la (superman and batman)', (done)=>
      TweetStoreService.findUserTweets @superman0.screen_name(), 2, (err, twtList)=>
      TweetStoreService.findStreamerTweets @superman0.streamer_screen_name(), (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 8
        # tweets should come out in reverse order
        (uValue twtList[0]).should.equal (uValue @superman3)
        (uValue twtList[1]).should.equal (uValue @superman2)
        (uValue twtList[2]).should.equal (uValue @superman1)
        (uValue twtList[3]).should.equal (uValue @batman3)
        (uValue twtList[4]).should.equal (uValue @batman2)
        (uValue twtList[5]).should.equal (uValue @batman1)
        (uValue twtList[6]).should.equal (uValue @batman0)
        (uValue twtList[7]).should.equal (uValue @superman0)

        done()

    it '(findStreamerTweets limit6, la) find the 6 most recent tweets from la', (done)=>
      TweetStoreService.findStreamerTweets @superman0.streamer_screen_name(), 5, (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 5
        # tweets should come out in reverse order
        (uValue twtList[0]).should.equal (uValue @superman3)
        (uValue twtList[1]).should.equal (uValue @superman2)
        (uValue twtList[2]).should.equal (uValue @superman1)
        (uValue twtList[3]).should.equal (uValue @batman3)
        (uValue twtList[4]).should.equal (uValue @batman2)
        twtList[4].text().should.equal @batman2.text();
        done()

    it '(findAllTweets)', (done)=>
      TweetStoreService.findAllTweets (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 12
        # tweets should come out in reverse order
        (uValue twtList[0]).should.equal (uValue @superman3)
        (uValue twtList[1]).should.equal (uValue @flash3)
        (uValue twtList[2]).should.equal (uValue @superman2)
        (uValue twtList[3]).should.equal (uValue @superman1)
        (uValue twtList[4]).should.equal (uValue @flash2)
        (uValue twtList[5]).should.equal (uValue @batman3)
        (uValue twtList[6]).should.equal (uValue @flash1)
        (uValue twtList[7]).should.equal (uValue @batman2)
        (uValue twtList[8]).should.equal (uValue @batman1)
        (uValue twtList[9]).should.equal (uValue @flash0)

        (uValue twtList[10]).should.equal (uValue @batman0)
        (uValue twtList[11]).should.equal (uValue @superman0)
        done()

    it '(findAllTweets limit6)', (done)=>
      TweetStoreService.findAllTweets 6, (err, twtList)=>
        should.not.exist err, 'err'
        should.exist twtList, 'tweetList'
        twtList.length.should.equal 6
        # tweets should come out in reverse order
        (uValue twtList[0]).should.equal (uValue @superman3)
        (uValue twtList[1]).should.equal (uValue @flash3)
        (uValue twtList[2]).should.equal (uValue @superman2)
        (uValue twtList[3]).should.equal (uValue @superman1)
        (uValue twtList[4]).should.equal (uValue @flash2)
        (uValue twtList[5]).should.equal (uValue @batman3)
        done()

  describe 'delete tweets', =>

    it '(delete tweet)', (done)=>
      tweet = @superman3
      tweet.save()
      TweetStoreService.tweetCount (err, numTweets)=>                                                    # number of total tweets
        TweetStoreService.findUserTweets tweet.screen_name(), 0, (err, userTweets)=>                  # list of user tweets
          TweetStoreService.findStreamerTweets tweet.streamer_screen_name(), 0, (err, streamerTweets)=>  # list of streamer tweets
            tweet.delete()                                                                          # delete a tweet
            TweetStoreService.tweetCount (err, tweetsLeft)=>                                             # number of total tweets left
              (expect tweetsLeft).to.equal (numTweets-1), 'tweets left'
              TweetStoreService.findUserTweets tweet.screen_name(), 0, (err, userTweetsLeft)=>           # list of user tweets left
                (expect userTweetsLeft.length).to.equal (userTweets.length - 1) , 'user tweets left'
                TweetStoreService.findStreamerTweets tweet.streamer_screen_name(), 0, (err, streamerTweetsLeft)=> # list of streamer tweets left
                  (expect streamerTweetsLeft.length).to.equal (streamerTweets.length-1) , 'streamer tweets left'
                  done()

  describe 'auto prune tweet', =>
    it '(userTweetCount superman) = 3', (done)=>
      TweetStoreService.findUserTweets superman0.screen_name(), 0, (err, userTweets)=>                  # list of user tweets
        (expect userTweets.length).to.equal 3
        done()
    it '(streamerTweetCount superman) = 7', (done)=>
      TweetStoreService.findStreamerTweets superman0.streamer_screen_name(), 0, (err, userTweets)=>                  # list of user tweets
        (expect userTweets.length).to.equal 7
        done()
    it '(tweetCount) = 11', (done)=>
      TweetStoreService.tweetCount (err, count)=>
        (expect count).to.equal 11
        done()

    # save 10 superman tweets, only 5 should remain
    it '(save @superman0)', (done)=> @superman0.save().should.equal true; Util.aMoment(done)
    it '(save @superman1)', (done)=> @superman1.save().should.equal true; Util.aMoment(done)
    it '(save @superman2)', (done)=> @superman2.save().should.equal true; Util.aMoment(done)
    it '(save @superman3)', (done)=> @superman3.save().should.equal true; Util.aMoment(done)
    it '(save @superman4)', (done)=> @superman4.save().should.equal true; Util.aMoment(done)
    it '(save @superman5)', (done)=> @superman5.save().should.equal true; Util.aMoment(done)
    it '(save @superman6)', (done)=> @superman6.save().should.equal true; Util.aMoment(done)
    it '(save @superman7)', (done)=> @superman7.save().should.equal true; Util.aMoment(done)
    it '(save @superman8)', (done)=> @superman8.save().should.equal true; Util.aMoment(done)
    it '(save @superman9)', (done)=> @superman9.save().should.equal true; Util.aMoment(done)
    it '-> saved 10 superman tweets', (done)=> (expect true).to.equal true; Util.aMoment(done)

    it '(userTweetCount superman): pruned to 5 ', (done)=>
      TweetStoreService.findUserTweets superman0.screen_name(), 0, (err, userTweets)=>                  # list of user tweets
        (expect userTweets.length).to.equal 5
        (uValue userTweets[0]).should.equal (uValue @superman9)
        done()
    it '(streamerTweetCount superman): pruned to 9', (done)=>
      TweetStoreService.findStreamerTweets superman0.streamer_screen_name(), 0, (err, userTweets)=>                  # list of user tweets
        (expect userTweets.length).to.equal 9
        done()
    it '(tweetCount): pruned to 13', (done)=>
      TweetStoreService.tweetCount (err, count)=>
        (expect count).to.equal 13
        done()

  describe 'final state', =>
    before (done)=>
      deleteFixtureTweets()
      done()

    it '(tweetCount) ends at 0', (done)=>
      TweetStoreService.tweetCount (err, count)=>
        (expect count).to.equal 0
        done()

    it 'database is empty', (done)=>
      redis.keys '*', (err, keys)=>
        keys.should.have.length 0
        done()


