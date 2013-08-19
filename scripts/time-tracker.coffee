# Description:
#   Log an amount of time for an issue of a repository.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot log [number][m|h|d] for [repository] on [issueNumber] - log work time for the specified issue
#   hubot log help - get some info about the existing repositories



module.exports = (robot) ->
  
  unitNames = {m : "minute", h : "hour", d : "day"}

  # domain = "http://localhost:9000"
  domain = "http://timer.scm.io"


  repositories = {
    # "philippotto/ttest" : ["ttest"]
    "scalableminds/oxalis" : ["oxalis", "ox"]
    "scalableminds/shellgame" : ["shellgame", "sg"]
    "scalableminds/brainflight" : ["brainflight", "bf"]
    "scalableminds/time-tracker" : ["time-tracker", "tt"]
  }

  getKnownRepositories = ->

    repoDescriptions = []
    
    for name, aliases of repositories

      repoDescriptions.push "- #{name} or " + (alias for alias in aliases).join(" or ")
    
    repoDescriptions = repoDescriptions.join("\n")
    

  aliasToRepository = (alias) ->

    for repo, aliases of repositories

      if aliases.indexOf(alias) > -1
        return repo

    return false


  robot.respond /log ([\d]+(\.[\d]+)?)([mhd]) for ([\w\/]+) on (\w+)/i, (msg) ->
    
    apiToken = process.env.HUBOT_TIMETRACKER_API_TOKEN

    value = msg.match[1]
    unit = msg.match[3]
    repositoryAlias = msg.match[4]
    issue = msg.match[5]

    if apiToken

      if not repository = aliasToRepository repositoryAlias

        repoDescriptions = getKnownRepositories()
        msg.send "Sorry, but I don't know repository #{repositoryAlias}. Please choose from the following:\n#{repoDescriptions}"
        return

      unitOutput = value + " " + unitNames[unit] + if value > 1 then "s" else ""
      msg.send "You want to log #{unitOutput} for repository #{repositoryAlias} on issue #{issue}."
      
      timestamp = Date.now()
      duration = value + unit

      url = "#{domain}/repos/#{repository}/issues/#{issue}" + "?accessKey=#{apiToken}"

      req = robot.http(url)
      
      req.header('Content-Length', 0)
      req.header('Content-type', 'application/json')
      
      req.post(JSON.stringify {duration, timestamp}) (err, response, body) ->
    
        if err != null
    
          msg.send("There was an error submitting the entry:" + err)

          return

        msg.send "Your work was successfully acknowledged."

    else

      msg.send("Please set a timetracker API token. hubot set env HUBOT_TIMETRACKER_API_TOKEN=\"abc123\".")


  robot.respond /log help/i, (msg) ->

    repoDescriptions = getKnownRepositories()

    msg.send """Use the following syntax: hubot log [number][m|h|d] for [repository] on [issueNumber]
    You may choose from the following repositories:\n#{repoDescriptions}"""
