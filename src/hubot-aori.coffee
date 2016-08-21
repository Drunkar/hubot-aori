# Description:
#   Send aori image via hubot-google-images.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot あおり|煽り|aori
#   hubot あおりいか|アオリイカ
#
# Author:
#   Drunkar <drunkars.p@gmail.com>
#

AORI_IMAGE_QUERY = "煽り画像"
SQUID_IMAGE_URL = "https://upload.wikimedia.org/wikipedia/commons/2/25/Caribbean_reef_squid.jpg"

module.exports = (robot) ->
  robot.hear /(しね|.*死ね.*|.*氏ね.*|.*タヒね.*|シネ|.*殺す.*|.*ころす.*|コロス|.*うるせぇしね.*|.*うっせーしね.*|.*うっせしね.*|.*(マジ|まじ)(うんこ|ウンコ).*|.*(うんこ|ウンコ野郎).*|カス|ゴミ)/i, (msg) ->
    imageMe msg, AORI_IMAGE_QUERY, (url) ->
      msg.send url

  robot.respond /(あおり|煽り|aori)/i, (msg) ->
    imageMe msg, AORI_IMAGE_QUERY, (url) ->
      msg.send url

  robot.respond /(あおりいか|アオリイカ)/i, (msg) ->
    msg.send SQUID_IMAGE_URL

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
  if googleCseId
    # Using Google Custom Search API
    googleApiKey = process.env.HUBOT_GOOGLE_CSE_KEY
    if !googleApiKey
      msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
      msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
      return
    q =
      q: query,
      searchType:'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      fields:'items(link)',
      cx: googleCseId,
      key: googleApiKey
    if animated is true
      q.fileType = 'gif'
      q.hq = 'animated'
      q.tbs = 'itp:animated'
    if faces is true
      q.imgType = 'face'
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          if res.statusCode is 403
            msg.send "Daily image quota exceeded, using alternate source."
            deprecatedImage(msg, query, animated, faces, cb)
          else
            msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureResult(image.link, animated)
        else
          msg.send "Oops. I had trouble searching '#{query}'. Try later."
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
              .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
  else
    msg.send "Google Image Search API is no longer available. " +
      "Please [setup up Custom Search Engine API](https://github.com/hubot-scripts/hubot-google-images#cse-setup-details)."
    deprecatedImage(msg, query, animated, faces, cb)

deprecatedImage = (msg, query, animated, faces, cb) ->
  # Show a fallback image
  imgUrl = process.env.HUBOT_GOOGLE_IMAGES_FALLBACK ||
    'http://i.imgur.com/CzFTOkI.png'
  imgUrl = imgUrl.replace(/\{q\}/, encodeURIComponent(query))
  cb ensureResult(imgUrl, animated)

# Forces giphy result to use animated version
ensureResult = (url, animated) ->
  if animated is true
    ensureImageExtension url.replace(
      /(giphy\.com\/.*)\/.+_s.gif$/,
      '$1/giphy.gif')
  else
    ensureImageExtension url