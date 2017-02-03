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

  robot.http("http://thecatapi.com/api/images/get?format=src").get() (err, response, body ) ->

    msg.send response.request.uri.href
