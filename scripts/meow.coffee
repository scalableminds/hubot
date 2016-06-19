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

  robot.respond /meow/i, (msg) ->
    msg.send "http://thecatapi.com/api/images/get?format=src"
