fs = require 'fs'
path = require 'path'
async = require 'async'
Page = require './page'
yaml = require 'js-yaml'
highlighter = require 'highlight.js'
marked = require 'marked'

readYAML = (filename, callback) ->
  ### read and try to parse *filename* as yaml ###
  async.waterfall [
    (callback) ->
      fs.readFile filename, callback
    (buffer, callback) ->
      try
        rv = yaml.load buffer.toString()
        traverseJson rv, (item, key) ->
          item[key] = parseMarkdown(item[key])
        callback null, rv
      catch error
        error.filename = filename
        error.message = "parsing #{ path.basename(filename) }: #{ error.message }"
        callback error
  ], callback

traverseJson = (item, callback) ->
  for k, v of item
    if k in ["markdown", "md", "body"]
      callback.apply(this, [item, k])
    if typeof v is "object"
      traverseJson v, callback

parseMarkdown = (data) ->
  marked.setOptions
    gfm: true
    tables: true
    breaks: true
    pedantic: false
    sanitize: true
    highlight: (code, lang) ->
      return highlighter.highlightAuto(code)

  marked(data)

class YamlPage extends Page

YamlPage.fromFile = (filename, base, callback) ->
  async.waterfall [
    async.apply readYAML, path.join(base, filename)
    (metadata, callback) =>
      page = new this filename, metadata.content or '', metadata
      callback null, page
  ], callback

module.exports = YamlPage
