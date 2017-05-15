# Hubot Twitter timeline

Enables your [hubot](https://github.com/github/hubot) to display the Twitter timeline of a configured Twitter user in a room.

## Dependencies

[twit](https://github.com/ttezel/twit) 2.2.5

## Configuration

Expose the following environment variables:

* HUBOT_TWITTER_TIMELINE_ROOM
* HUBOT_TWITTER_TIMELINE_ENABLE_COLORS
* HUBOT_TWITTER_TIMELINE_CONSUMER_KEY
* HUBOT_TWITTER_TIMELINE_CONSUMER_SECRET
* HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN
* HUBOT_TWITTER_TIMELINE_ACCESS_TOKEN_SECRET

Optionally you can add some color, if used within the IRC adapter by setting
* HUBOT_TWITTER_TIMELINE_ENABLE_COLORS=true

Resources within the tweets (urls and media links) can be instantly expanded by setting
* HUBOT_TWITTER_TIMELINE_EXPAND_URL=true

## Commands

None

## Notes

This script is using the Twitter [User streams](https://dev.twitter.com/docs/streaming-apis/streams/user). 

## Author

Johannes Graf (@grafjo)

## License

hubot-twitter-timeline is released under the MIT License. See the bundled LICENSE file for details.
