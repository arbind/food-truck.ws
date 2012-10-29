class ModelBase
  attributes: null

  constructor: (@attributes) ->

  id: ()-> @get('id')

  get: (attName) -> @attributes[attName] || null
  set: (attName, value) -> 
    return unless attName
    @attributes[attName] = value

  # subclasses can define an @service attribute in order to implement these
  save:       ()-> (@Service.save @)
  delete:     ()-> (@Service.delete @)
  update: (atts)-> (@Service.udpate @, atts)
  updateAttribute: (field, value)-> (@Service.udpateAttributes @, field, value)

  toJSON: () -> JSON.stringify @attributes

module.exports = ModelBase
