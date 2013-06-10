# Description:
#   Pugme is the most important thing in your life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot pug me - Receive a pug
#   hubot pug bomb N - get N pugs

apiKey = process.env.HUBOT_TUMBLR_API_KEY

getImage = (msg, id) ->

  msg.http("http://api.tumblr.com/v2/blog/programmerryangosling.tumblr.com/posts?api_key=#{apiKey}&limit=1&offset=#{id}").get() (err, response, body ) ->

    post = JSON.parse(body)
    msg.send post.response.posts[0].photos[0].original_size.url


getGoslingPic = (msg) ->

  msg.http("http://api.tumblr.com/v2/blog/programmerryangosling.tumblr.com/info?api_key=#{apiKey}").get() (err, response, body) ->

    blog = JSON.parse(body)
    postCount = blog.response.blog.posts
    id = Math.floor(Math.random() * postCount)

    getImage(msg, id)


module.exports = (robot) ->

  robot.respond /give me some love/i, (msg) ->

    getGoslingPic(msg)


  robot.respond /give me some love (\d+)/i, (msg) ->
    count = msg.match[1] - 1 || 5

    for i in [count..1]
      getGoslingPic(msg)
