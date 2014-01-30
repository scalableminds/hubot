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

module.exports = (robot) ->
  robot.router.post "/hubot/say", (req, res) ->

    {roomName,message} = req.body
    messageReescaped = message.replace("\\n","\n")
    robot.logger.info "Message received for room #{roomName}:\n#{messageReescaped}"

    if message? and roomName?
      robot.adapter.connector.getRooms (err, rooms, stanza) =>
        if rooms
          for room in rooms
            if room['name'] == roomName
              robot.messageRoom(room['xmpp_jid'], messageReescaped)

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'