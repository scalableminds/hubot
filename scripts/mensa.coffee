# Description:
#   Prints todays mensa menu
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot mensa - Receive the mensa menu

async = require("async")
moment = require("moment")
canteenIds = process.env.HUBOT_CANTEEN_IDS?.split(",")

module.exports = (robot) ->

  getCanteenName = (id, msg, callback) ->

    async.waterfall [
      (callback) -> robot.http("http://openmensa.org/api/v2/canteens/#{id}").get()(callback)
      (response, body, callback) ->
        try
          name = JSON.parse(body).name
          callback(null, name)
        catch error
          callback("Error parsing name of Canteen \##{id}")

    ], callback

  getCanteenMeals = (id, msg, callback) ->

    async.waterfall [
      (callback) -> robot.http("http://openmensa.org/api/v2/canteens/#{id}/days/#{moment().format("YYYY-MM-DD")}/meals").get()(callback)
      (response, body, callback) ->

        if response.statusCode != 200
          callback(null, ["No meal available for today"])

        else
          try
            meals = JSON.parse(body).map( (meal) -> meal.name )
            callback(null, meals)
            
          catch error
            callback(null, ["Error while parsing meals"])
          
    ], callback


  getCanteenNameAndMeals = (id, msg, callback) ->

    async.parallel(
      name : (callback) -> getCanteenName(id, msg, callback)
      meals : (callback) -> getCanteenMeals(id, msg, callback)
      callback
    )


  robot.respond /mensa/i, (msg) ->

    if canteenIds
      async.parallel(
        canteenIds.map( (id) -> (callback) -> getCanteenNameAndMeals(id, msg, callback))
        (err, canteens) ->
          if err
            msg.send("oops. #{err}")
          else
            canteens.forEach( (canteen) -> 
              msg.send(
                """#{canteen.name}
                #{canteen.meals.map( (a) -> "* #{a}" ).join("\n")}"""
              )
            )
      )
    else
      msg.send "Please set some canteen ids from http://openmensa.org/api/v2/canteens. hubot set env HUBOT_CANTEEN_IDS=\"1,2,3\""

