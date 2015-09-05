# Load neuralNetwork config
neuralNetworkConfig = (config = require './config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

brain = require 'brain'
fs = require 'fs'

# Create brain
beerBrain = new brain.NeuralNetwork()

fs.readFile './brain.json', (err, data) ->
	if err
		throw err
	else
		json = fs.readFileSync './brain.json'
		beerBrain.fromJSON json

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

		classes = []
		for beerStyle, probability of output
			classes.push {beerStyle: beerStyle, probability: probability}
		sorted = (lodash.sortBy classes, 'probability').reverse()
		console.log sorted
		process.exit(0)
