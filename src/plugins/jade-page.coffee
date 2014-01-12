
fs = require 'fs'
path = require 'path'
async = require 'async'
Page = require './page'
jade = require 'jade'
yaml = require 'js-yaml'

readJade = (filename, callback) ->
  ### read and try to parse *filename* as jade ###
  async.waterfall [
    (callback) ->
      fs.readFile filename, callback
    (buffer, callback) ->
      try
        rv = jade.compile buffer.toString(),
          filename: filename
          pretty: true
        callback null, rv
      catch error
        error.filename = filename
        error.message = "parsing #{ path.basename(filename) }: #{ error.message }"
        callback error
  ], callback


class JadePage extends Page
  getHtml: (base) ->
    fn = jade.compile @_content,
      pretty: true

    @_html ?= fn()
    return @_html

JadePage.fromFile = (filename, base, callback) ->
  async.waterfall [
    (callback) ->
      fs.readFile path.join(base, filename), callback
    (buffer, callback) ->
      JadePage.extractMetadata buffer.toString(), callback
    (result, callback) =>
      {jd, metadata} = result
      page = new this filename, jd, metadata
      callback null, page
  ], callback

JadePage.extractMetadata = (content, callback) ->
  parseMetadata = (source, callback) ->
    try
      callback null, yaml.load(source) or {}
    catch error
      callback error
  
  # split metadata and jd content

  if content[0...3] is '---'
    # "Front Matter"
    result = content.match /-{3,}\s([\s\S]*?)-{3,}\s([\s\S]*)/
    if result?.length is 3
      metadata = result[1]
      jd = result[2]
    else
      metadata = ''
      jd = content
  else
    # old style metadata
    logger.warn 'Deprecation warning: page metadata should be encapsulated by at least three dashes (---)'
    split_idx = content.indexOf '\n\n'
    metadata = content.slice(0, split_idx)
    jd = content.slice(split_idx + 2)

  async.parallel
    metadata: (callback) ->
      parseMetadata metadata, callback
    jd: (callback) ->
      callback null, jd
  , callback

module.exports = JadePage