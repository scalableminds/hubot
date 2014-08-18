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
superagent = require("superagent")

caCert = require("fs").readFileSync(__dirname + "/../certs/scm.pem", "utf8")

projectRooms = {
  "director": "braingames",
  "levelcreator": "braingames",
  "stackrenderer": "braingames",
  "oxalis": "oxalis",
  "time-tracker": "time-tracker"
}

auth = process.env.X_AUTH_TOKEN
unless auth?
  console.log "Missing X_AUTH_TOKEN in environment: please set and try again"
  process.exit(1)


fireAdminEvent = (cmd, msg, data) ->
  url = "https://config.scm.io:5000/#{cmd}/trigger"
  if(msg.message.room == projectRooms[data['project']])
    superagent
        .post(url)
        .ca(caCert)
        .set('X-AUTH-TOKEN', auth)
        .set('Content-type', 'application/json')
        .send(data)
        .end((err, res) ->
          if res.status == 401
            msg.send res.text
          else if err or res.status != 200
            msg.send "There was an error firing off your event"
          else
            msg.send "Your event was fired"
        )
  else if msg.message.room == "Shell"
    msg.send("Data #{JSON.stringify(data)} was send with #{cmd} event to #{url}")
  else
    msg.send("Switch to room #{projectRooms[data['project']]} for administrating #{data['project']}")

module.exports = (robot) ->

  robot.respond new RegExp("salt (start|stop|restart) #{projectsRegExp} #{branchRegExp} #{modeRegExp}?$","i"), (msg) ->
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4] || "dev"
    data = {'source' : project, 'cmd': cmd, 'project': project, 'branch': branch, 'mode': mode }
    fireAdminEvent(cmd, msg, data)

  robot.respond new RegExp("salt (install|remove) #{projectsRegExp} #{branchRegExp} #{modeRegExp} ?([0-9]+)?$", "i"), (msg) ->
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4]
    build_number = msg.match[5]
    data = {'source' : project, 'project': project, 'branch': branch, 'mode': mode, 'build_number': build_number }
    fireAdminEvent(cmd, msg, data)