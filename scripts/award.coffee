# Description:
#   Print most active github committer for a specified repository
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot award X - get employee of the week for repo X
#   hubot award X n - get employee of week -n for repo X

apiToken = process.env.HUBOT_GITHUB_API_TOKEN

module.exports = (robot) ->

	compareScore = (a, b) ->

		scoreA = getScore(a)
		scoreB = getScore(b)

		return scoreB - scoreA

	getScore = (employee) ->

		weekData = employee.weeks[employee.weeks.length - @week]
		score = weekData.a - weekData.d

	getStats = (msg) ->

		robot.http("https://api.github.com/repos/scalableminds/#{msg.match[1]}/stats/contributors?access_token=#{apiToken}").get() (err, response, body) ->

			stats = JSON.parse(body)

			if stats.length

				@week = Math.max(1, msg.match[2] || 1)
				highestScore = 0
				# if nobody did work, I'm the king ;)
				king = "daniel-wer"

				date = new Date(stats[0].weeks[stats[0].weeks.length - @week].w * 1000)
				dateString = date.getDate() + "-" + (date.getMonth() + 1) + "-" + date.getFullYear()
				msg.send("Employee of the week award for repository #{msg.match[1]} (#{dateString}) goes to...\n")

				stats.sort(compareScore)

				if getScore(stats[0])
					for i in [0...Math.min(3, stats.length)]
						score = getScore(stats[i])
						msg.send("#{i + 1}. - ..:: #{stats[i].author.login} - #{score} ::..") if score
				else
					msg.send("Nobody did work - shame on all of us!")

			else if response.statusCode == 202
				msg.send("Stats are being generated, please try again!")
			else
				msg.send("Repository not found")

	robot.respond /award ([a-zA-Z-._0-9]+) ?(\d+)?/i, (msg) ->

		if apiToken
			getStats(msg)
		else
			msg.send("Please set a github API token. hubot set env HUBOT_GITHUB_API_TOKEN=\"abc123\"")