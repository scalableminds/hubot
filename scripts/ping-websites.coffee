# Description:
#   Pings our systems/sercers and sends response time
#
# Dependencies:
#   none
#
# Configuration:
#   none
#
# Commands:
#   hubot ping websites - pings all added websites
#   hubot add <your site> to pinglist - adds the given url to the collection
#   hubot remove <your site> from pinglist - removes the given url from the collection
#
# Notes:
#   Code is mostly reused from maddox's keep-alive.coffee
#
# Author:
#   dominic-braeunlein


HTTP = require "http"
URL  = require "url"


ping = (url, msg) ->

  parsedUrl = URL.parse(url)
  options   =
    host: parsedUrl.host
    port: parsedUrl.port || 80
    path: parsedUrl.path
    method: 'GET'

  start = new Date()
  req = HTTP.request options, (res) ->
    body = ""
    res.setEncoding("utf8")
    res.on "data", (chunk) ->
      body += chunk
    res.on "end", () ->
      data =
        response:
          body: body
          status: res.statusCode
      msg.send("#{url} (#{res.statusCode}): #{new Date() - start} ms")

  req.on "error", (e) ->
    msg.send("#{url}: not responding")

  req.end()


module.exports = (robot) ->

  robot.respond /ping websites/i, (msg) ->
    if robot.brain.data.pinglist?
      for url in robot.brain.data.pinglist
          try
            ping(url, msg)
          catch e
            msg.send "there is something wrong with: #{url}"
    else
      msg.send "No websites to ping."


  robot.respond /add (.*) to pinglist$/i, (msg) ->
    url = msg.match[1]

    robot.brain.data.pinglist ?= []

    if url in robot.brain.data.pinglist
      msg.send "It was already added."
    else
      robot.brain.data.pinglist.push url
      msg.send "OK."


  robot.respond /remove (.*) from pinglist$/i, (msg) ->
    url = msg.match[1]

    robot.brain.data.pinglist ?= []
    idx = robot.brain.data.pinglist.indexOf(url)
    
    if idx >= 0
      robot.brain.data.pinglist.splice(idx, 1);
      msg.send "And it's gone."
    else
      msg.send "#{url} wasn't even in the list."