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

imageMe = function(msg, query, animated, faces, cb) {
  var googleApiKey, googleCseId, q, url;
  if (typeof animated === 'function') {
    cb = animated;
  }
  if (typeof faces === 'function') {
    cb = faces;
  }
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID;
  if (googleCseId) {
    googleApiKey = process.env.HUBOT_GOOGLE_CSE_KEY;
    if (!googleApiKey) {
      msg.robot.logger.error("Missing environment variable HUBOT_GOOGLE_CSE_KEY");
      msg.send("Missing server environment variable HUBOT_GOOGLE_CSE_KEY.");
      return;
    }
    q = {
      q: query,
      searchType: 'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      fields: 'items(link)',
      cx: googleCseId,
      key: googleApiKey
    };
    if (animated === true) {
      q.fileType = 'gif';
      q.hq = 'animated';
      q.tbs = 'itp:animated';
    }
    if (faces === true) {
      q.imgType = 'face';
    }
    url = 'https://www.googleapis.com/customsearch/v1';
    return msg.http(url).query(q).get()(function(err, res, body) {
      var error, i, image, len, ref, ref1, response, results;
      if (err) {
        if (res.statusCode === 403) {
          msg.send("Daily image quota exceeded, using alternate source.");
          deprecatedImage(msg, query, animated, faces, cb);
        } else {
          msg.send("Encountered an error :( " + err);
        }
        return;
      }
      if (res.statusCode !== 200) {
        msg.send("Bad HTTP response :( " + res.statusCode);
        return;
      }
      response = JSON.parse(body);
      if (response != null ? response.items : void 0) {
        image = msg.random(response.items);
        return cb(ensureResult(image.link, animated));
      } else {
        msg.send("Oops. I had trouble searching '" + query + "'. Try later.");
        if ((ref = response.error) != null ? ref.errors : void 0) {
          ref1 = response.error.errors;
          results = [];
          for (i = 0, len = ref1.length; i < len; i++) {
            error = ref1[i];
            results.push((function(error) {
              msg.robot.logger.error(error.message);
              if (error.extendedHelp) {
                return msg.robot.logger.error("(see " + error.extendedHelp + ")");
              }
            })(error));
          }
          return results;
        }
      }
    });
  } else {
    msg.send("Google Image Search API is no longer available. " + "Please [setup up Custom Search Engine API](https://github.com/hubot-scripts/hubot-google-images#cse-setup-details).");
    return deprecatedImage(msg, query, animated, faces, cb);
  }
};