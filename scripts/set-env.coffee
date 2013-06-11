# Description:
#   Set an environment variable for hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot set env SECRET="123456" - Setting an environment variable

fs = require("fs")

module.exports = (robot) ->

  robot.respond /set env (.+)=\"?([^\"]+)\"?$/i, (msg) ->

    fs.readFile(".env", (err, envFile) ->

      if err
        msg.send "Ooops. I wasn't able to read .env file. #{err}"

      else

        # read env variables from file
        env = {}
        envFile.toString().split("\n").forEach( (line) ->

          if matches = line.match(/^export (.+)=\"?([^\"]+)\"?$/m)

            [a, key, value] = matches
            env[key] = value

          return

        )

        # set new env variable
        [a, key, value] = msg.match
        env[key] = value

        # make new .env file
        newEnvFile = Object.keys(env)
          .map((key) -> "export #{key}=\"#{env[key]}\"")
          .join("\n")

        fs.writeFile(".env", newEnvFile, (err) ->

          if err
            msg.send "What?! I can't write the .env file. #{err}"

          else
            msg.send "Ok. Now you got your shiny new variable set. Please restart me."
        )
    )