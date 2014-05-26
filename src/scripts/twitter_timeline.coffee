# Description
#   Displays the Twitter timeline of a configured Twitter user in a room.
#
# Dependencies:
#   "twit": "1.1.15"
#
# Configuration:
#   HUBOT_TWITTER_TIMELINE_ROOM
#   HUBOT_TWITTER_TIMELINE_CONSUMER_KEY
#   HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET
#   HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN
#   HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET
#
# Commands:
#   None
#
# Notes:
#   None
#
# Author:
#   grafjo


Twit = require "twit"

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
    msg = "[@#{tweet.user.screen_name}] "
    msg += if tweet.retweeted_status then "RT @#{tweet.retweeted_status.user.screen_name}: #{tweet.retweeted_status.text}" else tweet.text
    robot.logger.debug msg
    robot.messageRoom process.env.HUBOT_TWITTER_TIMELINE_ROOM, msg

  stream.on "disconnect", (disconnectMessage) ->
    robot.logger.warning "I've got disconnected from Twitter timeline. Apparently the reason is: #{disconnectMessage}"

  stream.on "reconnect", (request, response, connectInterval) ->
    robot.logger.info "I'll reconnect to Twitter timeline in #{connectInterval} ms"

  stream.on "connected", (response) ->
    robot.logger.info "I'm conntected to Twitter timeline"
