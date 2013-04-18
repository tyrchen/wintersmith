async = require 'async'
{ncp} = require 'ncp'
fs = require 'fs'
path = require 'path'
{fileExists} = require './common' # cli common
{logger} = require '../common' # lib common
moment = require 'moment'

sys = require('sys')
exec = require('execSync').stdout

done_msg='✔ Done!'

usage = """

  usage: wintersmith deploy

  Build and deploy the site

  example:

    $ wintersmith deploy

"""


deploy = (argv) ->

  console.log "Building the site..."

  console.log exec("wintersmith build")

  process.chdir('./build')
  console.log exec("git add .")
  console.log exec("git add -u")
  message = "Site update at #{moment().format("YYYY-MM-DD hh:mm")}"
  console.log "Commit the code..."
  console.log exec('git commit -m "' + message + '"')
  console.log "Push and deploy the code..."
  console.log exec "git push origin master"
  process.chdir('..')
  console.log "#{done_msg} Github pages deploy completely"


module.exports = deploy
module.exports.usage = usage
module.exports.options = {}