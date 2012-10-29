sys = require 'sys'
{exec} = require 'child_process'


task 'spec:server', 'Test server-side specs', (options)->
  exec './node_modules/.bin/mocha -R spec --compilers cofee:coffee-script spec/server/*/*', (err, stdout, stderr) ->
  #   throw err if err
    sys.print "Test server-side specs\n" + stdout + stderr + "\n----------------------------------------\n"

task 'spec:client', 'Test client-side specs', (options)->
  exec './node_modules/.bin/mocha -R spec --compilers cofee:coffee-script spec/client/*/*', (err, stdout, stderr) ->
    throw err if err
    sys.print "Test client-side specs\n" + stdout + stderr + "\n----------------------------------------\n"

task 'spec:user', 'Test user-interaction specs (headless-browser)', (options)->
  exec './node_modules/.bin/mocha -R spec --compilers cofee:coffee-script spec/user/*/*', (err, stdout, stderr) ->
    throw err if err
    sys.print "Test user-interaction specs (headless-browser)\n" + stdout + stderr + "\n----------------------------------------\n"

task 'spec', 'Run all client and server specs', (options)->
  invoke 'spec:server'
  # invoke 'spec:client'
  # invoke 'spec:user'
