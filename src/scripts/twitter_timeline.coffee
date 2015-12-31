# Description
#   Displays the Twitter timeline of a configured Twitter user in a room.
#
# Dependencies:
#   "twit": "1.1.15"
#
# Configuration:
#   HUBOT_TWITTER_TIMELINE_ROOM
#   HUBOT_TWITTER_TIMELINE_ENABLE_COLORS
#   HUBOT_TWITTER_TIMELINE_CONSUMER_KEY
#   HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET
#   HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN
#   HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET
#
# Commands:
#   None
#
# Notes:
#   When using the irc adapter, then it's possible to enable tweet colors via HUBOT_TWITTER_TIMELINE_ENABLE_COLORS=true
#
# Author:
#   grafjo


Twit = require "twit"

useIrcColors = process.env.HUBOT_TWITTER_TIMELINE_USE_IRC_COLORS
if useIrcColors
  IrcColors = require "irc-colors"

module.exports = (robot) ->

  unless process.env.HUBOT_TWITTER_TIMELINE_ROOM
    robot.logger.warning "The HUBOT_TWITTER_TIMELINE_ROOM environment variable not set"
    return
  unless process.env.HUBOT_TWITTER_TIMELINE_CONSUMER_KEY
    robot.logger.warning "The HUBOT_TWITTER_TIMELINE_CONSUMER_KEY environment variable not set"
    return
  unless process.env.HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET
    robot.logger.warning "The HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET environment variable not set"
    return
  unless process.env.HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN
    robot.logger.warning "The HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN environment variable not set"
    return
  unless process.env.HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET
    robot.logger.warning "The HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET environment variable not set"
    return

  twit = new Twit
    consumer_key: process.env.HUBOT_TWITTER_TIMELINE_CONSUMER_KEY,
    consumer_secret: process.env.HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET,
    access_token: process.env.HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN,
    access_token_secret: process.env.HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET

  stream = twit.stream "user"

  stream.on "tweet", (tweet) ->
    if useIrcColors
      msg = IrcColors.lime "@#{tweet.user.screen_name}"
    else
      msg = "@#{tweet.user.screen_name}"
    msg = "[#{msg}] "

    if tweet.retweeted_status
      if useIrcColors
        msg += IrcColors.aqua "RT @#{tweet.retweeted_status.user.screen_name}: "
      else
        msg += "RT @#{tweet.retweeted_status.user.screen_name}: "
      msg += tweet.retweeted_status.text
    else
      msg += tweet.text

    # Expand links if any
    urlExpander = process.env.HUBOT_TWITTER_TIMELINE_EXPAND_URL
    if urlExpander
      nl= "\n"
      space=" "
      if useIrcColors
        pre = IrcColors.lime "#URL["
        preimg = IrcColors.lime "#IMG["
        sep = IrcColors.lime "|"
        end = IrcColors.lime "]"
      else
        pre = "#URL["
        preimg = "#IMG["
        sep = "|"
        end = "]"
      urlnum = 0
      imgnum = 0
      media = tweet.entities.media
      if Array.isArray(media)
        for thing in media
          imgnum++
          robot.logger.debug "----- IMG # " + imgnum + "------"
          robot.logger.debug thing
          msg += [ nl, imgnum, preimg, space, thing.media_url, space, end ].join("")

      urls = tweet.entities.urls
      if Array.isArray(urls)
        for thing in urls
          lurl = "http://api.longurl.org/v2/expand?url=" + encodeURIComponent(thing.url) + "&title=1" + "&format=json"
          robot.http(lurl)
            .header('Accept', 'application/json')
            .get() (err, res, body) ->
              if err
                robot.logger.warning "Encountered an error :( #{err}"
              else if res.statusCode > 300
                robot.logger.warning "something smells funny: #{res}"
              else
                urlnum++
                robot.logger.debug "----- URL # " + urlnum + "------"
                robot.logger.debug thing
                urlinfo = JSON.parse body
                robot.logger.debug urlinfo
                if urlinfo.title
                  robot.messageRoom process.env.HUBOT_TWITTER_TIMELINE_ROOM, [ urlnum, pre, space, urlinfo['long-url'], space, sep, space, urlinfo['title'], space, end ].join("")
                else
                  robot.messageRoom process.env.HUBOT_TWITTER_TIMELINE_ROOM, [ urlnum, pre, space, urlinfo['long-url'], space, end ].join("")

    robot.logger.debug msg
    robot.messageRoom process.env.HUBOT_TWITTER_TIMELINE_ROOM, msg

  stream.on "disconnect", (disconnectMessage) ->
    robot.logger.warning "I've got disconnected from Twitter timeline. Apparently the reason is: #{disconnectMessage}"

  stream.on "reconnect", (request, response, connectInterval) ->
    robot.logger.debug "I'll reconnect to Twitter timeline in #{connectInterval} ms"

  stream.on "connected", (response) ->
    robot.logger.debug "I'm conntected to Twitter timeline"
