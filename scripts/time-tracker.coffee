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
#   hubot log and load - refresh repositories
#   hubot log help - get some info about the existing repositories

request = require("request")
_ = require("lodash-node")
Levenshtein = require("levenshtein")
moment = require("moment")


# domain = "http://localhost:9000"
domain = "http://timer.scm.io"

apiToken = process.env.HUBOT_TIMETRACKER_API_TOKEN

class RepositoryStore

  constructor: (@robot) ->

    nullMsg = {send : ->}
    @getRepositories(nullMsg)


  getRepositories: (msg) ->

    url = domain + "/api/repos?accessKey=#{apiToken}"
    req = @robot.http(url)

    req.get() (error, response, body) =>
      if !error and response.statusCode == 200
        @repositories = JSON.parse(body)
        msg.send @repositories.length + " repositories were loaded successfully."
      else
        msg.send "An error occured when loading the repositories (statusCode: " + response.statusCode + "): " + error



  getMostMatchingRepository: (givenRepoName, msg) ->

    if not @repositories
      throw new Exception("No repositories found. Try hubot log and load.")

    maxDistance = 4
    givenRepoName = givenRepoName.toLowerCase()

    reposWithDistances = @repositories.map((repo) ->
      repoName = repo.name.toLowerCase().split("/")[1]
      distance = new Levenshtein(givenRepoName, repoName).distance
      { repo, distance }
    )

    matchingRepo = _.min(reposWithDistances, (r) -> r.distance )

    if matchingRepo.distance < maxDistance
      if matchingRepo.distance != 0
        msg.send "You probably meant " + matchingRepo.repo.name
      return matchingRepo.repo
    else
      return null


module.exports = (robot) ->

  unitNames = {m : "minute", h : "hour", d : "day"}

  repositoryStore = new RepositoryStore(robot)

  robot.respond /log and load/i, (msg) ->

    repositoryStore.getRepositories(msg)

  robot.respond /log ([\d]+(\.[\d]+)?)([mhd]) for ([\w\/]+) on (\w+)/i, (msg) ->

    apiToken = process.env.HUBOT_TIMETRACKER_API_TOKEN

    value = msg.match[1]
    unit = msg.match[3]
    repositoryStr = msg.match[4]
    issue = msg.match[5]

    if not apiToken
      msg.send("Please set a timetracker API token. hubot set env HUBOT_TIMETRACKER_API_TOKEN=\"abc123\".")
      return

    repository = repositoryStore.getMostMatchingRepository(repositoryStr, msg)

    if not repository
      msg.send "Sorry, I couldn't recognize the repository :("
      return

    unitOutput = value + " " + unitNames[unit] + if value > 1 then "s" else ""
    msg.send "You want to log #{unitOutput} for repository #{repository.name} on issue #{issue}."

    duration = value + unit
    dateTime = moment.utc()
    url = "#{domain}/api/repos/#{repository.id}/issues/#{issue}?accessKey=#{apiToken}"

    req = robot.http(url)
    req.header('Content-Length', 0)
    req.header('Content-type', 'application/json')

    req.post(JSON.stringify {duration, dateTime}) (err, response, body) ->

      if err != null or response.statusCode != 200

        msg.send("There was an error submitting the entry.")
        msg.send(err)
        msg.send(body)

        return

      msg.send "Your work was successfully acknowledged."


  robot.respond /log help/i, (msg) ->

    repoDescriptions = getKnownRepositories()

    msg.send """Use the following syntax: hubot log [number][m|h|d] for [repository] on [issueNumber]
    You may choose from the following repositories:\n#{repoDescriptions}"""
