global.node_env = process.env.NODE_ENV || global.localEnvironment || 'test'
console.log "***********************"
console.log "#{node_env} environment"
console.log "-----------------------"

fs = (require 'fs')

# global space for parameter passing :)
global.appData = {}

# application paths
global.rootPath = {}
rootDir = process.cwd()
rootPath.path =       (rootDir + '/')
rootPath.db =         (rootPath.path + 'db/')
rootPath.config =     (rootPath.path + 'config/')
rootPath.public =     (rootPath.path + 'public/')

rootPath.app =        (rootPath.path + 'app/')
rootPath.utils =      (rootPath.app + 'utils/')
rootPath.assets =     (rootPath.app + 'assets/')
rootPath.models =     (rootPath.app + 'models/')
rootPath.services =   (rootPath.app + 'services/')
rootPath.extentions = (rootPath.app + 'extentions/')

global.requireModuleInFile = (path, filename)->
  filePath = path+filename
  try
    if String.prototype.toClassName
      className = filename.toClassName()
      clazz = require filePath    # if anything is exported, assume that it is a Class
      global[className] = clazz   # make the class available globally
    else
      require filePath
      console.log "loaded file #{filename}"
  catch exception
    console.log ""
    console.log "!! could not load #{filename} from #{path}"
    throw exception

global.requireModulesInDirectory = (path)->
  (requireModuleInFile path, f) for f in fs.readdirSync(path)

# load some usefull stuff
requireModulesInDirectory rootPath.extentions
requireModulesInDirectory rootPath.utils
# global.Util = (require rootPath.utils + 'util')
# global.puts = (require rootPath.utils + 'puts')
# global.log  = (require rootPath.utils + 'log')

# set application configurations
global.redisURL = null # runtime environment would override this, if using redis
global.redisDBNumber = 99999 # runtime environment would also override this to one of the DB numbers below:
global.redisTestDB = 2
global.redisDevelopmentDB = 1
global.redisProductionDB = 0

global.mongoURL = null


# load runtime environment
require "./environments/#{node_env}"

require rootPath.models + 'index'
require rootPath.services + 'index'

# connect to mondoDB
if mongoURL
  global.mongoDB = (require 'mongoskin').db mongoURL
  # +++ create database if it does not exists?

# connect to redis
if redisURL
  global.redis = require('redis-url').connect(redisURL)
  redis.on 'connect', =>
    redis.send_anyways = true
    console.log "redis: connection established"
    redis.select redisDBNumber, (err, val) => 
      redis.send_anyways = false
      redis.selectedDB = redisDBNumber
      console.log "redis: selected DB ##{redisDBNumber} for #{env}"
      redis.emit 'db-select', redisDBNumber
      unless debug
        redis.keys '*', (err, keys)->
          console.log "redis: #{keys.length} keys present in DB ##{redisDBNumber} "
