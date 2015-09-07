# Load config
microbrewitConfig = (require '../config/config').microbrewit

# Require packages
bluebird = require 'bluebird'
bluebird.longStackTraces();
fs = bluebird.promisifyAll require 'fs'
http = bluebird.promisifyAll require 'http'
normalize = require './normalize'
hopsFormulas = require './hopsformulas'
io = require './io'

fetchMicrobrewitBeers = () ->
  io.readFile('./beers.json')
    .catch((error) ->
      console.log 'Fetch from api instead'
      io.fetchDataFromUrl(microbrewitConfig.apiUrl + '/beers?size=4000')
        .then((data) ->
          io.writeFile './beers.json', data))
    .then((data) ->
      console.log 'We got data after readFile'
      return data)
    .then(JSON.parse)
    .then((json) ->
      console.log 'return da beers'
      return json.beers)
    .catch(SyntaxError, (error) ->
      console.err "File contains invalid json: " + error
      throw new Error 'Could not read ./beers.json')

getIngredients = (recipe, ingredientType) ->
  ingredients = []
  for step in recipe.mashSteps
    for ingredient in step[ingredientType]
      ingredients.push ingredient
  for step in recipe.boilSteps
    for ingredient in step[ingredientType]
      ingredients.push ingredient
  for step in recipe.mashSteps
    for ingredient in step[ingredientType]
      ingredients.push ingredient
  return ingredients

getHops = (recipe) ->
  hops = getIngredients recipe.recipe, 'hops'
  for hop in hops
    hop.boilVolume = recipe.recipe.boilSteps[0].boilVolume
  totalTinseth = 0
  for hop in hops
    hop.tinseth = (hopsFormulas.formulas.tinseth hop).ibu
    totalTinseth += hop.tinseth

  normalized = []
  for hop in hops
    normalized.push {name: hop.name, value: hop.tinseth / totalTinseth}

  return normalized

getFermentables = (recipe) ->
  fermentables = getIngredients recipe.recipe, 'fermentables'

  totalAmount = 0
  for fermentable in fermentables
    totalAmount += fermentable.amount

  normalized = []
  for fermentable in fermentables
    normalized.push {name: fermentable.name, value: fermentable.amount / totalAmount}
  return normalized

transformBeersToNeuralNetworkInput = (beers) ->
  trainingCases = []
  # Prep beer recipes
  for beer in beers
    trainingCase = {
      input:
        abv: normalize.normalizeABV beer.abv.standard
        ibu: normalize.normalizeIBU beer.ibu.standard
        srm: normalize.normalizeSRM beer.srm.standard
        og: normalize.normalizeGravity beer.recipe.og
        fg: normalize.normalizeGravity beer.recipe.fg
      output: {}}
    trainingCase.output[beer.beerStyle.name] = 1

    hops = getHops beer
    fermentables = getFermentables beer
    for hop in hops
      if not trainingCase.input[hop.name]?
        trainingCase.input[hop.name] = hop.value
      else
        trainingCase.input[hop.name] += hop.value

    for fermentable in fermentables
      if not trainingCase.input[fermentable.name]?
        trainingCase.input[fermentable.name] = fermentable.value
      else
        trainingCase.input[fermentable.name] += fermentable.value

    trainingCases.push trainingCase

  return trainingCases

exports.fetchMicrobrewitBeers = fetchMicrobrewitBeers
exports.transformBeersToNeuralNetworkInput = transformBeersToNeuralNetworkInput
