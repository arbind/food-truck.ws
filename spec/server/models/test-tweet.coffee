require (process.cwd() + '/config/application')

describe 'Tweet', ->
  @la = 'la'; @sf = 'sf'
  @tweet1 = new Tweet {id:"tweet-1", text: "first tweet", user:{screen_name:'grill', id:'grill-1'}, streamer: {screen_name:la}}
  @tweet2 = new Tweet {id:"tweet-2", text: "second tweet", user:{screen_name:'bbq', id:'bbq-1'}, streamer: {screen_name:sf}}

  before (done) ->
    done()

  it '(constructor attributes)', (done) =>
    @tweet1.exists
    @tweet2.exists
    @tweet1.id().should.not.equal @tweet2.id()
    done()

  it '.screen_name', (done) =>
    @tweet1.screen_name().should.equal 'grill'
    @tweet2.screen_name().should.equal 'bbq'
    done()

  it '.streamer_screen_name', (done) =>
    @tweet1.streamer_screen_name().should.equal @la
    @tweet2.streamer_screen_name().should.equal @sf
    done()

  it '.toJSON', (done) =>
    jsonValue = '{"streamer":"la","id":1,"text":"first tweet"}' # Exactly formated
    json = JSON.parse jsonValue
    @tweet1 = new Tweet json
    @tweet1.toJSON().should.equal jsonValue                     # Matches Exact format
    done()
