chai = require 'chai'
chai.should()

describe 'example', ->
  before (done) ->
    @x = 3
    done()

  it 'checks', (done) ->
    @x.exists
    done()