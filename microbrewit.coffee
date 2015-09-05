# Load config
microbrewitConfig = (require './config').microbrewit

# Require packages
bluebird = require 'bluebird'
fs = bluebird.promisifyAll require 'fs'
http = bluebird.promisifyAll require 'http'

bluebird.longStackTraces();

fetchMicrobrewitBeersFromFile = () ->
  fs.readFileAsync('./beers.json')
    .then((data) ->
      console.log "Read ./beers.json"
      return data)
    .catch((error) ->
      console.error "Unable to read file because: " + error
      throw new Error 'Could not read ./beers.json')

fetchFromAPI = (url) ->
  return new Promise (resolve, reject) ->
    http.get(url, (result) ->
      body = ''

      result.on 'data', (chunk) ->
        body += chunk

      result.on 'end', () ->
        resolve body

    ).on 'error', (error) ->
      reject error

fetchMicrobrewitBeersFromAPI = () ->
    fetchFromAPI(microbrewitConfig.apiUrl + '/beers?size=4000')
      .then((data) ->
        console.log 'Fetched beers from ' + microbrewitConfig.apiUrl + '/beers'
        return data)
      .catch((error) ->
        console.log 'Get req failed from ' + microbrewitConfig.apiUrl + '/beers'
        throw error)

storeMicrobrewitBeers = (data) ->
  console.log 'Store file!'
  fs.writeFileAsync('./beers.json', data)
    .then(() ->
      console.log "Wrote ./beers.json"
      data)
    .catch((error) ->
      console.log 'Could not write ./beers.json. Consider manual deletion.'
      data)

fetchMicrobrewitBeers = () ->
  fetchMicrobrewitBeersFromFile()
    .catch((error) ->
      console.log 'Fetch from api instead'
      fetchMicrobrewitBeersFromAPI()
        .then(storeMicrobrewitBeers))
    .then(JSON.parse)
    .then((json) ->
      return json.beers)
    .catch(SyntaxError, (error) ->
      console.err "File contains invalid json: " + error
      throw new Error 'Could not read ./beers.json')

exports.fetchMicrobrewitBeers = fetchMicrobrewitBeers
