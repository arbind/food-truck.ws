## [food-truck.ws](http://food-truck.ws)
# A TweetStream Service ( *Configured for Food Trucks* )

### To Start Server:
````
npm install
npm start
````

### To Start Client:
````
browse to [ http://localhost:8888 ]
````

### To Execute Specs:
````
mocha -R spec --compilers cofee:coffee-script spec/*/*/*
````

### The MVP:
1. twitter oauth to setup food truck streamers
2. listen for tweets from thousands of food trucks around the world
3. keeps the 10 most recent tweets in redis (food-truck.ws/:food_truck_screen_name)
4. updates food truck crafts in mongodb with recent activity (+++ TODO)
5. triggers a rank recalculation on every tweet from a food truck (+++ TODO)
6. identifies tweets with location / schedule info (+++ TODO)
7. parsed out trusted location / schedule info from tweets (where possible) (+++ TODO)
8. ui for manual disambiguation of location / schedule info (if parser can't figure it out) (+++ TODO)


### TO DO
````
+ push to heroku (or delete existing heroku app, and create a new one with this codebase)
+ setup config: use cakefile to execute specs
+ build missing functionality (#4-8)
+ Add a page for twitter oauth login flow
+ food-truck.ws/user/:food_truck_screen_name
+ food-truck.ws/streamer/:food_truck_screen_name
+ food-truck.ws/tweets/:food_truck_screen_name
````
