Fs   = require 'fs'
Path = require 'path'

module.exports = (robot) ->
  path = Path.resolve __dirname, 'src/scripts'
  Fs.exists path, (exists) ->
    if exists
      for file in Fs.readdirSync(path)
        robot.loadFile path, file
        robot.parseHelp Path.join(path, file)

