# Description:
#   Logs work and calculates total work time
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot start work <user> [<topic>] - save beginning of work
#   hubot stop work <user> - save end of work
#   hubot show work <user> - display working record for <user>
#   hubot reset work <user> - Delete work logs for <user>

prefix = "time_"

module.exports = (robot) ->

  getMinutes = (timeObject) ->

    unless timeObject.end?
      return 0
    return (timeObject.end - timeObject.start) / 1000 / 60

  getMinutesString = (timeObject) ->

    unless timeObject.end?
      return "---"
    return ( getMinutes(timeObject) ).toFixed(0)

  printUserRecord = (user, msg) ->

    worktimes = robot.brain.get(prefix + user)

    unless worktimes?
      msg.send("User #{user} does not exist.")
      return

    msg.send("=== Working record for #{user} ===")
    prevDate = new Date(0)
    minutesPerDay = 0

    for time in worktimes
      
      date = new Date(time.start)
      if date.toDateString() != prevDate.toDateString()
        if minutesPerDay > 0
          msg.send(" --> Worked #{minutesPerDay.toFixed(0)} minutes this day")
        msg.send("")
        msg.send("== #{date.toDateString()} ==")
        minutesPerDay = 0

      msg.send("#{getMinutesString(time)} \t #{time.topic}")
      minutesPerDay += getMinutes(time)
      prevDate = date

    if minutesPerDay > 0
      msg.send(" --> Worked #{minutesPerDay.toFixed(0)} minutes this day")


  robot.respond /show work ([\w.\-_]+)/i, (msg) ->
    printUserRecord(msg.match[1].trim().toLowerCase(), msg)


  robot.respond /reset work ([\w.\-_]+)/i, (msg) ->

    user  = msg.match[1].trim().toLowerCase()
    robot.brain.set(prefix + user, [])
    robot.brain.save()
    msg.send("Did #{user} ever do any work?")


  robot.respond /start work ([\w.\-_]+)(?: ([\w\d .\-_]+))?/i, (msg) ->
  
    user  = msg.match[1].trim().toLowerCase()
    topic = msg.match[2]?.trim() || ""

    worktimes = robot.brain.get(prefix + user) || []

    if worktimes.length > 0 and not worktimes[ worktimes.length - 1 ].end?
      msg.send( "You still need to stop working. Can't work twice, stupid." )

    else
      worktimes.push({
        start : new Date().getTime()
        end   : null
        topic : topic
      })
      robot.brain.set(prefix + user, worktimes)
      robot.brain.save()
      topicString = if topic.length == 0 then "" else " working on #{topic}"
      msg.send("Starting work for user " + user + topicString)


  robot.respond /stop work ([\w.\-_]+)/i, (msg) ->
  
    user = msg.match[1].trim().toLowerCase()
    worktimes = robot.brain.get(prefix + user) || []

    if worktimes.length < 1 or worktimes[ worktimes.length - 1 ].end?
      msg.send( "You can't stop working before even starting it." )

    else
      lastWork = worktimes[ worktimes.length - 1 ]
      lastWork.end = new Date().getTime()
      robot.brain.set(prefix + user, worktimes)
      robot.brain.save()
      msg.send("#{user}, you have worked #{getMinutesString(lastWork)} minutes.")