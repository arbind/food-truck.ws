# Access level   Read, write, and direct messages 
class TwitterConsumers extends ModelBase
  @FoodTruckWS:
    consumer:
      key: 'ys0BKjMp79ZW6udBeCnGbg'
      secret: 'krLI6aRtS19lFglUkn87qUc2vyNWVk1N4df2ENzsTE'
      callback_url: 'http://www.food-truck.ws/oauth/twitter/foodtruckws/callback'

    sudo_oauth_tokens:
      access_token:  '896339995-laItgXQVdZWKuCO7vD8kkNqKb1xob924deJEU1wX'
      access_token_secret: 'WtVEB1NKuTgBAVgvCmNzJhuC8LLpxNsbYaUBJjX0'

  @access_tokens = (consumer, user_oauth_tokens) ->
    consumer_key: consumer.key
    consumer_secret: consumer.secret
    callback_url:  consumer.callback_url
    access_token: user_oauth_tokens.access_token
    access_token_secret: user_oauth_tokens.access_token_secret

  @FoodTruckWS_oauth_tokens = () ->
    @access_tokens @FoodTruckWS.consumer, @FoodTruckWS.sudo_oauth_tokens

module.exports = TwitterConsumers
