# Description:
#   Let's you interact with our infrastructure
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot install_dev branch version - start/stop services

branchRegExp = "([a-zA-Z-._0-9]+)"

PROJECT_ROOM = "webknossos-bots"

auth = process.env.X_AUTH_TOKEN
unless auth?
  console.log "Missing X_AUTH_TOKEN in environment: please set and try again"
  process.exit(1)

module.exports = (robot) ->

  robot.respond new RegExp("install_dev #{branchRegExp} ([0-9]+)$", "i"), (msg) ->
    branch = msg.match[1]
    version = msg.match[2]
    if msg.message.room == PROJECT_ROOM
      msg.send("Deploying webknossos/#{branch} ##{version} on dev.scm.io...")
      robot.http("http://dev.scm.io:3000/")
        .header('Content-Type', 'application/json')
        .post(JSON.stringify({ token: process.env.X_AUTH_TOKEN, branch: branch, version: version })) (err, res) ->
          if res.statusCode == 401
            msg.send "Unauthorized"
          else if err or res.statusCode != 200
            msg.send "There was an error "
          else
            msg.send "Deployed webknossos/#{branch} ##{version} on dev.scm.io"
    else
      msg.send("Switch to room #{PROJECT_ROOM} for administrating webknossos")

  robot.respond new RegExp("install_master ([0-9]+)$", "i"), (msg) ->
    version = msg.match[1]
    msg.send("Not implemented yet. Please SSH to `oxalis.at` and run `install_oxalis #{version}`.")

    # if msg.message.room == PROJECT_ROOM
    #   msg.send("Deploying webknossos/master ##{version} on oxalisone.oxalis.at...")
    #   robot.http("http://oxalis.at:3000/")
    #     .header('Content-Type', 'application/json')
    #     .post(JSON.stringify({ token: process.env.X_AUTH_TOKEN, branch: "master", version: version })) (err, res) ->
    #       if res.statusCode == 401
    #         msg.send "Unauthorized"
    #       else if err or res.statusCode != 200
    #         msg.send "There was an error "
    #       else
    #         msg.send "Deployed webknossos/master ##{version} on oxalisone.oxalis.at"
    # else
    #   msg.send("Switch to room #{PROJECT_ROOM} for administrating webknossos")

