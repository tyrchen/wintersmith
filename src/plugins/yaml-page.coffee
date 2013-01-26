fs = require 'fs'
path = require 'path'
async = require 'async'
Page = require './page'
yaml = require 'js-yaml'

readYAML = (filename, callback) ->
  ### read and try to parse *filename* as yaml ###
  async.waterfall [
    (callback) ->
      fs.readFile filename, callback
    (buffer, callback) ->
      try
        rv = yaml.load buffer.toString()
        callback null, rv
      catch error
        error.filename = filename
        error.message = "parsing #{ path.basename(filename) }: #{ error.message }"
        callback error
  ], callback

class YamlPage extends Page

YamlPage.fromFile = (filename, base, callback) ->
  async.waterfall [
    async.apply readYAML, path.join(base, filename)
    (metadata, callback) =>
      page = new this filename, metadata.content or '', metadata
      callback null, page
  ], callback

module.exports = YamlPage
