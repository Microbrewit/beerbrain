# Load neuralNetwork config
neuralNetworkConfig = (config = require '../config/config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
fs = require 'fs'
brain = require 'brain'
lodash = require 'lodash'
microbrewit = require './microbrewit'
io = require './io'

sampleRecipes = (recipes) ->
  splitIndex = Math.ceil recipes.length * 0.8
  shuffledRecipes = lodash.shuffle(recipes)
  return {
    trainingCases: shuffledRecipes[0..splitIndex],
    classificationCases: shuffledRecipes[splitIndex..recipes.length] }

train = () ->
  microbrewit.fetchMicrobrewitBeers()
    .then((beers) ->
      recipes = microbrewit.transformBeersToNeuralNetworkInput beers
      cases = sampleRecipes recipes
      return cases)
    .then((cases) ->
      io.writeFile('./cases.json', JSON.stringify cases.classificationCases)
        .then(() ->
          console.log 'Wrote sampled classification cases to file!'
          return cases)
        .catch(() ->
          console.error 'Could not write classification cases to file.'
          return cases))
    .then((cases) ->
      # Create brain
      beerBrain = new brain.NeuralNetwork()
      # Train the brain
      beerBrain.train cases.trainingCases, neuralNetworkConfig
      jsonNetwork = beerBrain.toJSON();
      io.writeFile('./brain.json', JSON.stringify jsonNetwork)
        .then((data) ->
          console.log 'brain.json was written!'
          process.exit 0))
    .catch((error) ->
      console.error 'Could not perform beer recipe classification training because:'
      console.error error
      process.exit(1))

classify = () ->
  io.readFile('./brain.json')
    .then((brainData) ->
      io.readFile('./cases.json')
        .then((casesData) ->
          return {
            brain: JSON.parse brainData
            cases: JSON.parse casesData}))
    .then((brainAndCases) ->
      # Create brain
      beerBrain = new brain.NeuralNetwork()
      # Read ze memory banks
      beerBrain.fromJSON brainAndCases.brain

      cases = brainAndCases.cases
      totalScore = 0
      for classifyCase in cases
        output = beerBrain.run classifyCase
        classes = []
        for beerStyle, probability of output
          classes.push {beerStyle: beerStyle, probability: probability}
        sorted = (lodash.sortBy classes, 'probability').reverse()

        topBeerStyleClassifications = lodash.map sorted[0..5], (output) ->
          output.beerStyle
        actualBeerStyle = Object.keys(classifyCase.output)[0]

        console.log topBeerStyleClassifications
        console.log actualBeerStyle

        if lodash.includes topBeerStyleClassifications, actualBeerStyle
          totalScore += 1

      console.log "Total score: #{totalScore}"
      console.log "Total cases #{cases.length}"
      percentCorrect = (totalScore/brainAndCases.cases.length) * 100
      console.log "Neural network classified #{percentCorrect}% correct."

      process.exit 0)
    .catch((error) ->
      console.error error
      process.exit 1)

exports.train = train
exports.classify = classify
