global.isPresent = (obj)->
  return true for own key, val of obj # hasOwnProperty of any key?
  return false

global.isEmpty = (obj)-> not isPresent(obj)
