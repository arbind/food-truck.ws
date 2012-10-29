global.node_env = process.env.NODE_ENV || global.localEnvironment || 'test'
console.log "***********************"
console.log "#{node_env} environment"
console.log "-----------------------"

# application paths
global.rootPath = {}
rootDir = process.cwd()
rootPath.path =     (rootDir + '/')
rootPath.config =   (rootPath.path + 'config/')
rootPath.app =      (rootPath.path + 'app/')
rootPath.db =       (rootPath.db + 'db/')
rootPath.public =   (rootPath.public + 'public/')
rootPath.models =   (rootPath.app + 'models/')
rootPath.services = (rootPath.app + 'services/')
rootPath.utils =    (rootPath.app + 'utils/')

# load some usefull stuff
global.Util = (require rootPath.utils + 'util')
global.puts = (require rootPath.utils + 'puts')
global.log  = (require rootPath.utils + 'log')

# set application configurations
global.redisURL = null # runtime environment would override this, if using redis
global.redisDBNumber = 99999 # runtime environment would also override this to one of the DB numbers below:
global.redisTestDB = 2
global.redisDevelopmentDB = 1
global.redisProductionDB = 0

# load runtime environment
require "./environments/#{node_env}"

# load app classes
(require rootPath.models + 'index')
(require rootPath.services + 'index')
(require rootPath.utils + 'index')

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
