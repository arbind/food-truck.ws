# [food-truck.ws](http://food-truck.ws)
================

## Processes Food Truck TweetStreams

### Note:
- The code base running on heroku at [food-truck.ws](http://food-truck.ws) needs to be merged into this code base

### MVP:
+ 1. twitter oauth to setup food truck streamers (+++ TODO: move code on heroku into this app)
+ 2. listen for tweets from thousands of food trucks around the world (+++ TODO: move code on heroku into this app)
+ 3. keeps the 10 most recent tweets in redis (food-truck.ws/:food_truck_screen_name)
+ 4. updates food truck crafts in mongodb with recent activity (+++ TODO)
+ 5. triggers a rank recalculation on every tweet from a food truck (+++ TODO)
+ 6. identifies tweets with location / schedule info (+++ TODO)
+ 7. parsed out trusted location / schedule info from tweets (where possible) (+++ TODO)
+ 8. ui for manual disambiguation of location / schedule info (if parser can't figure it out) (+++ TODO)

### Working TweetService Implementation (#3)
+ Stores Tweets in redis
+ Auto prunes the number of tweets
+ To Execute Specs:
  * mocha -R spec --compilers cofee:coffee-script spec/*/*/*

### TODO
+ setup config: use cakefile to execute specs
+ merge code: move code on heroku that listens to incomming tweets into this app (#1-2)
+ build missing functionality (#4-8)

# To start server
- npm install
- npm start
- (app does not do anything yet - code running on heroku will be moved into this app)
