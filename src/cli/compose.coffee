async = require 'async'
{ncp} = require 'ncp'
fs = require 'fs'
path = require 'path'
{fileExists} = require './common' # cli common
{logger} = require '../common' # lib common
moment = require 'moment'

types = ['post', 'slide', 'canvas']
themes =
  post: ['default']
  slide: ['beige', 'default', 'night', 'serif', 'simple', 'sky']
  canvas: ['default']

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

get_content = (type, theme, title) ->
  now = moment().format('YYYY-MM-DD HH:mm')
  content = {
    default: """
    ---
    template: #{type}.jade
    theme: #{theme}
    title: #{title}
    date: #{now}
    comments: true
    tags: []
    ---


    """,
    canvas: """
    template: #{type}.jade
    theme: #{theme}
    title: #{title}
    date: #{now}
    comments: true
    tags: []

    customer_segments:
      - List your target customers and users

    early_adopters:
      - List characteristics of your ideal customers

    problem:
      - List your top 1-3 problems

    existing_alternatives:
      - List how these problems are solved today

    unique_value_proposition:
      - Single, clear, compelling message that turns an unaware visitor into an interested prospect

    high_level_concept:
      - List your X for Y analogy (e.g. YouTube = Flickr for videos)

    solution:
      - Outline a possible solution for each problem

    channels:
      - List your path to customer

    revenue_stream:
      - List your source of revenue

    cost_structure:
      - List your fixed and variable costs

    key_metrics:
      - List the key numbers that tell you how your business is doing

    unfair_advantage:
      - Something that can't be easily copied or bought
    """
  }

  return content[type] || content['default']

get_ext = (type) ->
  ext = {
    default: '.markdown'
    canvas: '.yml'
  }
  return ext[type] || ext['default']

pluralize = (name) ->
  # simple plurialize function, just consider s / es
  if name[name.length-1] is 's'
    return name + 'es'
  return name + 's'

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

  dt = moment().format('YYYY-MM-DD')
  f = path.join process.cwd(), 'contents', pluralize(type), dt + '-' + title.toLowerCase().replace(/\s+/g, '-') + get_ext(type)

  data = get_content(type, theme, title)
  fs.writeFile f, data, (err) ->
    if err
      console.log err


module.exports = compose
module.exports.usage = usage
module.exports.options = options
