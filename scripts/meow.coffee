# Description:
#   Get a cat
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot meow - Get a cat

module.exports = (robot) ->

  robot.hear /meow/i, (msg) ->
    robot.http("http://thecatapi.com/api/images/get?format=html").get() (err, response, body) ->
      msg.send body.match(/src="(.*)"/)[1]
