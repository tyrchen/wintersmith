async = require 'async'
{ncp} = require 'ncp'
fs = require 'fs'
path = require 'path'
{fileExists} = require './common' # cli common
{logger} = require '../common' # lib common
moment = require 'moment'

types = ['post', 'slide']
themes =
  post: ['default']
  slide: ['beige', 'default', 'night', 'serif', 'simple', 'sky']

usage = """

  usage: wintersmith compose [options] <title>

  creates a new document with <title>

  options:

    -t, --type <name>    type to create new document from (defaults to 'article')
    -m, --theme <name>   theme to create new document from (defaults to 'default')

    available types are: #{ types.join(', ') }
    available themes are: TODO

  example:

    create a new slide
    $ wintersmith compose "my first slide" -t slide -m beige

"""

options =
  type:
    alias: 't'
    default: 'post'
  theme:
    alias: 'm'
    default: 'default'


compose = (argv) ->
  title = argv._[1]
  type = argv.type
  theme = argv.theme
  if !title? or !title.length
    logger.error 'Please specify the title of the document'
    return

  if type not in types
    logger.error 'unknown document type #{type}'
    return

  if theme not in themes[type]
    logger.error 'unknown document theme #{theme} for #{type}'
    return

  now = moment().format('YYYY-MM-DD hh:mm')
  dt = moment().format('YYYY-MM-DD')
  f = path.join process.cwd(), 'contents', type + 's', dt + '-' + title.replace(/\s+/g, '-') + '.markdown'

  data = """
  ---
  template: #{type}.jade
  theme: #{theme}
  title: #{title}
  date: #{now}
  comments: true
  tags: []
  ---


  """
  fs.writeFile f, data, (err) ->
    if err
      console.log err


module.exports = compose
module.exports.usage = usage
module.exports.options = options
