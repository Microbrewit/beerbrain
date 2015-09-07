# Load neuralNetwork config
neuralNetworkConfig = (config = require './config/config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
fs = require 'fs'
brain = require 'brain'
lodash = require 'lodash'
microbrewit = require './app/microbrewit'

microbrewit.fetchMicrobrewitBeers()
  .then((beers) ->
    trainingCases = microbrewit.transformBeersToNeuralNetworkInput beers


    # Create brain
    beerBrain = new brain.NeuralNetwork()
    #Train the brain
    beerBrain.train trainingCases, neuralNetworkConfig
    jsonNetwork = beerBrain.toJSON();
    fs.writeFileSync './brain.json', JSON.stringify jsonNetwork

    # Classify some random values
    # ABV = 10%
    # IBU = 40
    # SRM = 15
    output2 = beerBrain.run
      abv: 0.0642,
      ibu: 0.275,
      srm: 0.35,
      og: 0.21133333333333298,
      fg: 0.04999999999999967,
      Cascade: 0.48837209302325585,
      Citra: 0.5116279069767441,
      'Aromatic Malt': 0.04084937916141803,
      'Caramel / Crystal 40L': 0.08169875832283606,
      'Munich - Light 10L': 0.06118409213604463,
      'Pale 2-Row': 0.8162677703797013

    output = beerBrain.run
      abv: 0.0571,
      ibu: 0.09166666666666666,
      srm: 0.175,
      og: 0.19400000000000006,
      fg: 0.04999999999999967,
      Golding: 1,
      Aromatic: 0.040035273368606704,
      'Flaked Rice': 0.07998236331569665,
      'Flaked Wheat': 0.040035273368606704,
      Munich: 0.07998236331569665,
      'Pale Wheat': 0.12001763668430335,
       Pilsner: 0.6399470899470899



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
