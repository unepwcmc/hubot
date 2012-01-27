#Tests hubot interaction with PivotalTracker
#
#request = require 'request'
http = require 'http'
vows = require 'vows'
assert = require 'assert'

vows
  .describe('Ask hubot for all the projects')
  .addBatch
    'If there are projects' :
      topic: () ->
        request "http://www.google.com", @callback
        #http.get({'host': 'http://www.google.com', 'port': 8080, 'path': '/'}, @callback)

      '200 OK Returned': (error, res) ->
        console.log(res)
        #assert.equal res, 200
  .export(module)
