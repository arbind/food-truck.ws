# [food-truck.ws](http://food-truck.ws)
================

## Real-Time Processing of TweetStreams from Food Trucks

### MVP:
+ 1. listen for tweets from thousands of food trucks around the world  (+++ TODO: move code on heroku into this app)
+ 2. keeps the 10 most recent tweets in redis (food-truck.ws/:food_truck_id)
+ 3. updates food truck activity in mongodb (+++ TODO)
+ 4. triggers food truck rank to be recalculated based on recent activity (+++ TODO)
+ 5. identifies tweets that may have location or schedule info (+++ TODO)
+ 6. provides trusted location and schedule info, parsed out from tweets (where possible) (+++ TODO)
+ 7. ui for manual disambiguation of location and schedule info (if parser can't figure it out) (+++ TODO)

### Working TweetService Implementation (#2)
+ Stores Tweets in redis
+ Auto prunes the number of tweets
#### To Execute Specs:
mocha -R spec --compilers cofee:coffee-script spec/*/*/*

### TODO
+ merge code: move code on heroku that listens to incomming tweets into this app (#1)
+ config: set up cakefile to execute specs
+ build missing functionality (#3-7)

# To start server
- npm install
- npm start
- (app does not do anything yet - code running on heroku will be moved into this app)
