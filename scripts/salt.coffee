# Description:
#   Let's you interact with salt and our infrastructure
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot salt (start|stop|restart) (stackrenderer|levelcreator|director|oxalis|time-tracker) branch (prod|dev) - start/stop services
#   hubot salt install (stackrenderer|levelcreator|director|oxalis|time-tracker) branch (prod|dev) build_number
#   hubot salt remove  (stackrenderer|levelcreator|director|oxalis|time-tracker) branch (prod|dev)

projects = ["stackrenderer", "levelcreator", "director", "oxalis", "time-tracker"]
projectsRegExp = "(#{projects.join("|")})"
branchRegExp = "([a-zA-Z-._0-9]+)"
modeRegExp = "(prod|dev)"

sys = require('sys')
exec = require('child_process').exec

projectRooms = {
  "director": "braingames",
  "levelcreator": "braingames",
  "stackrenderer": "braingames",
  "oxalis": "oxalis",
  "time-tracker": "time-tracker"
}

url = 'https://0.0.0.0:5000/run' # dev
# url = 'https://0.0.0.0:9090/run' # prod

auth = process.env.X_AUTH_Token
# unless auth?
#   console.log "Missing X_AUTH_Token in environment: please set and try again"
#   process.exit(1)

module.exports = (robot) ->
  robot.respond new RegExp("salt (start|stop|restart) #{projectsRegExp} #{branchRegExp} #{modeRegExp}?$","i"), (msg) ->
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4] || "dev"
    data = JSON.stringify({
      'room' : project,
      'data' : {'cmd': cmd, 'project': project, 'branch': branch, 'mode': mode},
      'tag': 'hubot-services'
    })
    msg.http(url)
     .headers(Authorization: auth, 'Content-type': 'application/json')
     .post(data) (err, res, body) ->
       result = body
       if result in ['success']
          msg.send "Your event was fired"
       else
          msg.send "There was an error firing off your event"

  # robot.respond new RegExp("salt (install|remove) #{projectsRegExp} #{branchRegExp} #{modeRegExp} ?([0-9]+)?$", "i"), (msg) ->
  #   cmd = msg.match[1]
  #   project = msg.match[2]
  #   branch = msg.match[3]
  #   mode = msg.match[4]
  #   build_number = msg.match[5]
  #   data = JSON.stringify([msg, 'data' : {'project': project, 'branch': branch, 'mode': mode, 'build_number': build_number}, 'tag' : "#{cmd}_packages", projectRooms])
  #   if (cmd == "install" and build_number) or cmd == "remove"
  #     robot.http(dev)
  #       .post(data) (err, res, body) -> msg.send("OK")