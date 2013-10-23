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

sys = require('sys')
exec = require('child_process').exec

deploymentRoom = "deployment"

fireAdminEvent = (msg, data, tag) -> 
  cmd = "sudo salt-call event.fire_master #{JSON.stringify(data)} #{tag}"
  if msg.message.room == deploymentRoom
    exec(cmd,  (error, stdout, stderr) -> 
      if error == null
        msg.send("ok!")
      else
        msg.send("error: #{stderr} \n #{error}")
    )
  else if msg.message.room == "Shell"
    msg.send(cmd)
  else
    msg.send("Switch to room '#{deploymentRoom}' for doing administrative tasks")

module.exports = (robot) ->
  robot.respond /salt (start|stop|restart) (stackrenderer|levelcreator|director|oxalis) ([a-zA-Z-._0-9]+) (prod|dev)?$/i, (msg) ->
    cmd = msg.match[1]
    project = msg.match[2]
    branch = msg.match[3]
    mode = msg.match[4] || "dev"
    fireAdminEvent(msg, {'cmd': cmd, 'project': project, 'branch': branch, 'mode': mode}, "hubot-services")

