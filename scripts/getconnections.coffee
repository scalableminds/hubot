# Description:
#   Get Connections gives you information about when the next busses and trains will depart at the specified location and time.
#   If location or time is not specified, Griebnitzsee and the current time will be used.
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot get connections [for <aLocation>] [at <hh:mm>] - Receive next busses and trains for aLocation at hh:mm (when omitted, Griebnitzsee and current time is used)


baseURL = "http://smarou.com/get/"
resultCountToDisplay = 5
defaultLocationIdentifier = "station=Griebnitzsee+Bhf+(S)%2C+Potsdam&X=13.127424&Y=52.393861"
shamelessAdvertisement = "Maybe you can find what you wish on www.smarou.com?"

module.exports = (robot) ->

  getConnectionsForLocation = (msg, aString, minutes, hours) ->
    robot.http(baseURL + "getSug.php?query=" + aString).get() (err, response, body) ->
      data = JSON.parse(body)
      
      for index in [0...data.names.length]
        if data.types[index] == "1"
          msg.send "So, let's see what's departing at " + data.names[index]
          locationIdentifier = "X=" + data.x[index] + "&Y=" + data.y[index] + "&station=" + data.names[index] 
          getConnections msg, locationIdentifier, minutes, hours
          return
      
      msg.send "Sorry, I couldn't find the location you specified. " + shamelessAdvertisement

  getConnections = (msg, aStation, minutes, hours) ->
    if aStation == null
      aStation = defaultLocationIdentifier
      msg.send "So, let's see what's departing at Griebnitzsee"

    requestURL = baseURL + "scmNextParts.php?" + aStation
        
    if minutes and hours
      requestURL += "&hours=" + minutes + "&" + "minutes=" + hours

    robot.http(requestURL).get() (err, response, body) ->

      post = JSON.parse(body)
      
      if post.names.length == 0      
        msg.send "Sorry, I couldn't anything for your request. " + shamelessAdvertisement
      else
        for i in [0 ... Math.min(post.names.length, resultCountToDisplay+1)]
          msg.send post.times[i] + " " + post.names[i] + " -> " + post.destinations[i]

  robot.respond /get connections for (.*?)( at ([\d]{2}):([\d]{2}))?$/i, (msg) ->
    getConnectionsForLocation(msg, msg.match[1], msg.match[3], msg.match[4])

  robot.respond /get connections( at ([\d]{2}):([\d]{2}))?$/i, (msg) ->
    getConnections msg, null, msg.match[2], msg.match[3]