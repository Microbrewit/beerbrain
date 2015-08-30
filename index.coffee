# Load neuralNetwork config
neuralNetworkConfig = (config = require './config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
brain = require 'brain'
lodash = require 'lodash'
microbrewit = require './microbrewit'
normalize = require './normalize'

microbrewit.fetchMicrobrewitBeers()
  .then((beers) ->
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
      trainingCases.push trainingCase

      lodash.sample trainingCases


    # Create brain
    beerBrain = new brain.NeuralNetwork()

    #Train the brain
    beerBrain.train trainingCases, neuralNetworkConfig

    # Classify some random values
    # ABV = 10%
    # IBU = 40
    # SRM = 15
    output = beerBrain.run
      abv: normalize.normalizeABV 10
      ibu: normalize.normalizeIBU 24
      srm: normalize.normalizeSRM 6
      og: normalize.normalizeGravity 1.094
      fg: normalize.normalizeGravity 1.015


    # Make output into sortable array of objects with
    # beerStyle and probability properties.
    classes = []
    for beerStyle, probability of output
      classes.push {beerStyle: beerStyle, probability: probability}
    sorted = (lodash.sortBy classes, 'probability').reverse()
    console.log sorted
    process.exit(0))
  .catch((error) ->
    console.log 'Could not perform beer recipe classification training because:'
    console.log error
    process.exit(1))
