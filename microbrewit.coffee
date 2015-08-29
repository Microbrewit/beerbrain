# Load config
microbrewitConfig = (require './config').microbrewit

# Require packages
http = require 'http'

fetchMicrobrewitBeers = (trainingFunc) ->
  console.log "Fetching beers from " + microbrewitConfig.apiUrl
  http.get(microbrewitConfig.apiUrl + '/beers?size=4000', (result) ->
    body = ''

    result.on 'data', (chunk) ->
      body += chunk

    result.on 'end', () ->
      beers = (JSON.parse body).beers
      console.log "Fetched " + beers.length + "recipes"
      trainingFunc null, beers

  ).on 'error', (error) ->
    console.log error
    trainingFunc error

exports.fetchMicrobrewitBeers = fetchMicrobrewitBeers
