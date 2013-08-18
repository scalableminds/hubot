# Description:
#   Log an amount of time for an issue of a project.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot log [number][m|h|d] for [project] on [issueNumber] - get employee of the week for repo X

apiToken = process.env.HUBOT_TIMETRACKER_API_TOKEN

module.exports = (robot) ->
  
  unitNames = {m : "minute", h : "hour", d : "day"}

  projects = {
    "ttest" : "philippotto/ttest"
    "oxalis" : "scalableminds/oxalis"
    "time-tracker" : "scalableminds/time-tracker"
    "shellgame" : "scalableminds/shellgame"
    "brainflight" : "scalableminds/brainflight"
  }

  robot.respond /log ([\d]+(\.[\d]+)?)([mhd]) for ([\w\/]+) on (\w+)/i, (msg) ->

    value = msg.match[1]
    unit = msg.match[3]
    project = msg.match[4]
    issue = msg.match[5]

    # lookup alias
    if projects[project]
      project = projects[project] 

    else
      allProjects = ""
      for name of projects
        allProjects += ", #{name}"
      allProjects = allProjects.slice(2)
      msg.send "Sorry, but I don't know #{project}. Please choose from the following: #{allProjects}."
      return


    unitOutput = value + " " + unitNames[unit] + if value > 1 then "s" else ""

    msg.send "You want to log #{unitOutput} for project #{project} on issue #{issue}."

    if true or apiToken
      timestamp = Date.now()
      duration = value + unit

      url = "http://localhost:9000/repos/#{project}/issues/#{issue}"

      req = robot.http(url)
      req.header('Content-Length', 0)
      req.header('Content-type', 'application/json')
      
      req.post(JSON.stringify {duration, timestamp}) (err, response, body) ->
        if err != null
          msg.send("There was an error submitting the entry:" + err)
          return

        msg.send "Your work was successfully acknowledged."
        msg.send body

    else
      msg.send("Please set a timetracker API token. hubot set env HUBOT_TIMETRACKER_API_TOKEN=\"abc123\".")