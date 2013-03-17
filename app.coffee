#!/usr/bin/env coffee
express = require "express"
jade    = require "jade"
assets  = require "connect-assets"
stylus  = require "stylus"
nib     = require "nib"
fs      = require "fs"
http    = require 'http'
require "jumly-jade"
(require "jade-filters").setup jade

views_dir  = "#{__dirname}/views"
static_dir = "#{views_dir}/static"

app = express()
app.configure ->
  app.use stylus.middleware
    src: views_dir
    dest: static_dir
    compile: (str, path, fn)->
               stylus(str)
                 .set('filename', path)
                 .set('compress', true)
                 .use(nib()).import('nib')

  app.set 'port', (process.env.PORT || 3000)
  app.set "views", views_dir
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
 
  app.use '/public', express.static "#{__dirname}/public"
  app.use '/', express.static static_dir
  app.use app.router

  app.use express.cookieParser 'adf19dfe1a4bbdd949326870e3997d799b758b9b'
  app.use express.session()
  app.use assets src:"lib"

  app.use (req, res, next)->
    res.status 404
    res.render '404', req._parsedUrl


app.configure "development", ->
  app.use express.errorHandler()


fs = require "fs"
require "js-yaml"
version = fs.readFileSync("lib/version").toString().trim().split "\n"
ctx =
  VERSION     : version.join "-"
  VERSION_PATH: version[0]
  IMAGES_DIR  : "public/images"
  TESTED_VERSION:
    jquery: "1.9.1"
    coffeescript: "1.4.0"
  i18n: require "#{views_dir}/i18n.yaml"


index  = require("./routes") ctx
images = require("./routes/images") ctx

app.get "/",          index.en
app.get "/index.en",  index.en
app.get "/index.ja",  index.ja
app.get "/reference", index.reference
app.get "/try",       index.try
app.post "/images",   images.b64decode

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
