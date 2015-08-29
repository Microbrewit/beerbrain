# Load neuralNetwork config
neuralNetworkConfig = (config = require './config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
brain = require 'brain'
lodash = require 'lodash'
microbrewit = require './microbrewit'
normalize = require './normalize'

microbrewit.fetchMicrobrewitBeers (error, beers) ->
  if error then throw new Error 'Could not load beer recipes for training'

  trainingCases = []
  # Prep beer recipes
  for beer in beers
    trainingCase = {
      input:
        abv: normalize.normalizeABV beer.abv.standard
        ibu: normalize.normalizeIBU beer.ibu.standard
        srm: normalize.normalizeSRM beer.srm.standard
      output: {}}
    trainingCase.output[beer.beerStyle.name] = 1
    trainingCases.push trainingCase

    lodash.sample trainingCases


  # Create brain
  beerBrain = new brain.NeuralNetwork()

  #Train the brain
  beerBrain.train trainingCases, neuralNetworkConfig

  # Classify some random values
  # ABV = 3% normalized: 0.03
  # IBU = 11 normalized: 0.1
  # SRM = 12 normalized: 0.3
  output = beerBrain.run { abv: 0.03,  ibu: 0.1, srm: 0.3 }

  # Make output into sortable array of objects with
  # beerStyle and probability properties.
  classes = []
  for beerStyle, probability of output
    classes.push {beerStyle: beerStyle, probability: probability}
  sorted = (lodash.sortBy classes, 'probability').reverse()

  console.log sorted
