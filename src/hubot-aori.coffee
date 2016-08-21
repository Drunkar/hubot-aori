# Description:
#   Send aori image via hubot-google-images.
#
# Dependencies:
#   cheerio-httpcli
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

google_images = require('hubot-google-images')
AORI_IMAGE_QUERY = "煽り画像"
SQUID_IMAGE_URL = "https://upload.wikimedia.org/wikipedia/commons/2/25/Caribbean_reef_squid.jpg"

module.exports = (robot) ->
  robot.hear /(しね|.*死ね.*|.*氏ね.*|.*タヒね.*|シネ|.*殺す.*|.*ころす.*|コロス|.*うるせぇしね.*|.*うっせーしね.*|.*うっせしね.*|.*(マジ|まじ)(うんこ|ウンコ).*|.*(うんこ|ウンコ野郎).*|カス|ゴミ)/i, (msg) ->
    google_images.imageMe msg, AORI_IMAGE_QUERY, (url) ->
      msg.send url

  robot.respond /(あおり|煽り|aori)/i, (msg) ->
    google_images.imageMe msg, AORI_IMAGE_QUERY, (url) ->
      msg.send url

  robot.respond /(あおりいか|アオリイカ)/i, (msg) ->
    msg.send SQUID_IMAGE_URL