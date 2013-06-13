# Description:
#   Give me some love sends you romantic messages from Programmer Ryan Gosling
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot give me some love - Receive a gosling pic
#   hubot give me some love N - get N gosiling pics

apiKey = process.env.HUBOT_TUMBLR_API_KEY


module.exports = (robot) ->

  getImage = (msg, id) ->

    robot.http("http://api.tumblr.com/v2/blog/programmerryangosling.tumblr.com/posts?api_key=#{apiKey}&limit=1&offset=#{id}").get() (err, response, body ) ->

      post = JSON.parse(body)
      msg.send post.response.posts[0].photos[0].original_size.url


  getGoslingPic = (msg) ->

    robot.http("http://api.tumblr.com/v2/blog/programmerryangosling.tumblr.com/info?api_key=#{apiKey}").get() (err, response, body) ->

      blog = JSON.parse(body)
      postCount = blog.response.blog.posts
      id = Math.floor(Math.random() * postCount)

      getImage(msg, id)

      

  robot.respond /give me some love/i, (msg) ->

    if apiKey
      getGoslingPic(msg)
    else
      msg.send "Please set a tumblr API key. hubot set env HUBOT_TUMBLR_API_KEY=\"123\""


  robot.respond /give me some love (\d+)/i, (msg) ->
    
    if apiKey
      count = msg.match[1] - 1 || 5

      for i in [count..1]
        getGoslingPic(msg)
        
    else
      msg.send "Please set a tumblr API key. hubot set env HUBOT_TUMBLR_API_KEY=\"123\""
