# Require packages
bluebird = require 'bluebird'
bluebird.longStackTraces();
fs = bluebird.promisifyAll require 'fs'
http = bluebird.promisifyAll require 'http'

readFile = (path) ->
  fs.readFileAsync(path)
    .then((data) ->
      console.log "Read file"
      return data)
    .catch((error) ->
      console.error "Unable to read file because: " + error
      throw new Error 'Could not read ' + path)

fetchFromHttpServer = (url) ->
  return new Promise (resolve, reject) ->
    http.get(url, (result) ->
      body = ''

      result.on 'data', (chunk) ->
        body += chunk

      result.on 'end', () ->
        resolve body

    ).on 'error', (error) ->
      reject error

fetchDataFromUrl = (url) ->
    fetchFromHttpServer(url)
      .then((data) ->
        console.log 'Fetched beers from ' + url
        return data)
      .catch((error) ->
        console.log 'Get req failed from ' + url
        throw error)

writeFile = (path, data) ->
  console.log 'Store file!'
  fs.writeFileAsync(path, data)
    .then(() ->
      console.log "Wrote " + path
      return data)
    .catch((error) ->
      console.log 'Could not write ' + path + '. Consider manual deletion.'
      return data)

exports.fetchDataFromUrl = fetchDataFromUrl
exports.readFile = readFile
exports.writeFile = writeFile
