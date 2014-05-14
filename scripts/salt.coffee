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
#   hubot salt (start|stop|restart) (stackrenderer|levelcreator|director|oxalis) branch (prod|dev) - start/stop services
#   hubot salt install (stackrenderer|levelcreator|director|oxalis) branch (prod|dev) build_number
#   hubot salt remove  (stackrenderer|levelcreator|director|oxalis) branch (prod|dev)

projects = ["stackrenderer", "levelcreator", "director", "oxalis"]
projectsRegExp = "(#{projects.join("|")})"
newInstallProjects = ["time-tracker"]
newInstallProjectsRegExp = "(#{newInstallProjects.join("|")})"
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

fireAdminEvent = (msg, data, tag) -> 
  cmd = "sudo salt-call event.fire_master #{JSON.stringify(data).replace(/\"/g, "\\\"")} #{tag}"
  if msg.message.room == projectRooms[data['project']]
    exec(cmd,  (error, stdout, stderr) -> 
      if error == null
        msg.send("ok!")
      else
        msg.send("error: #{stderr} \n #{error}")
    )
  else if msg.message.room == "Shell"
    msg.send(cmd)
  else
    msg.send("Switch to room #{projectRooms[data['project']]} for administrating #{data['project']}")

module.exports = (robot) ->
  robot.respond new RegExp("salt (start|stop|restart) #{projectsRegExp} #{branchRegExp} #{modeRegExp}?$","i"), (msg) ->
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4] || "dev"
    fireAdminEvent(msg, {'cmd': cmd, 'project': project, 'branch': branch, 'mode': mode}, "hubot-services")

  robot.respond new RegExp("salt (install|remove) #{projectsRegExp} #{branchRegExp} #{modeRegExp} ?([0-9]+)?$", "i"), (msg) -> 
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4]
    build_number = msg.match[5]
    if (cmd == "install" and build_number) or cmd == "remove"
      fireAdminEvent(msg, {'project': project, 'branch': branch, 'mode': mode, 'build_number': build_number}, "#{cmd}_packages")
  
  robot.respond new RegExp("salt (install|remove) #{newInstallProjectsRegExp} #{branchRegExp} #{modeRegExp} ?([0-9]+)?$", "i"), (msg) -> 
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4]
    build_number = msg.match[5]
    if (cmd == "install" and build_number) or cmd == "remove"
      fireAdminEvent(msg, {'project': project, 'branch': branch, 'mode': mode, 'build_number': build_number}, "#{cmd}_packages_new")

  robot.respond new RegExp("salt find #{projectsRegExp} #{modeRegExp}", "i"), (msg) -> 
    project = msg.match[1]
    mode = msg.match[2]
    fireAdminEvent(msg, {'project': project, 'mode': mode}, "find_app")