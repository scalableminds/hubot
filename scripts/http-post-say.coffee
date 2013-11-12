# Description:
# "Accepts POST data and broadcasts it"
#
# Dependencies:
# None
#
# Configuration:
# None
#
# Commands:
# None
#
# URLs:
# POST /hubot/say
# message = <message>
# room = <room>
#
# curl -X POST http://localhost:8080/hubot/say -d message=lala -d room='#dev'
#
# Author:
# insom
# luxflux
# lesnail

roomNameToId = (name) -> 
  "52503_deployment@conf.hipchat.com"

module.exports = (robot) ->
  robot.router.post "/hubot/say", (req, res) ->

    {room,message} = req.body
    messageReescaped = message.replace("\\n","\n")
    robot.logger.info "Message received for room #{room}:\n#{messageReescaped}"

    if message? and room?
      robot.messageRoom(roomNameToId(room), messageReescaped)

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'