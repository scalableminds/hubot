# Description:
#   Feed me finds meal deliveries near you 
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot feed me FOOD - finds places serving FOOD in Potsdam
#   hubot feed me FOOD in LOCATION - finds places serving FOOD near LOCATION

apiKey = process.env.HUBOT_GOOGLE_PLACES_API_KEY
country = "Germany"
defaultLocation = "14482"


module.exports = (robot) ->

  getPlaceInfo = (msg, reference) ->

    robot.http("https://maps.googleapis.com/maps/api/place/details/json?key=#{apiKey}&reference=#{reference}&sensor=false").get() (err, response, body ) ->

      json = JSON.parse(body)

      if json.status == "OK"
        details = JSON.parse(body).result

        msg.send details.name + "\n" +
          "    " + details.formatted_address + "\n" + 
          "    " + details.formatted_phone_number + " - " + details.website + "\n\n"

      else
        msg.send "Something went wrong. I am sorry..."


  findPlaces = (msg, query) ->

    robot.http("https://maps.googleapis.com/maps/api/place/textsearch/json?key=#{apiKey}&query=#{query}&sensor=false&opennow&types=food|restaurant|meal_delivery|meal_takeaway").get() (err, response, body ) ->

      json = JSON.parse(body)

      if json.status == "OK"
        places = JSON.parse(body).results

        for i in [0...Math.min(places.length, 6)]
          getPlaceInfo(msg, places[i].reference)

      else
        msg.send "Something went wrong. I am sorry..."


  robot.respond /feed me ((.*) in )?(.*)/i, (msg) ->

    if apiKey
      if msg.match[2]
        query = msg.match[2] + " in " + msg.match[3] + ", " + country
      else
        query = msg.match[3] + " in " + defaultLocation + ", " + country

      findPlaces(msg, query)
      
    else 
      msg.send "Please set a Google Places API key. hubot set env HUBOT_GOOGLE_PLACES_API_KEY=\"123\""
