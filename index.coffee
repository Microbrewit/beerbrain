# Load neuralNetwork config
neuralNetworkConfig = (config = require './config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
fs = require 'fs'
brain = require 'brain'
lodash = require 'lodash'
microbrewit = require './microbrewit'
normalize = require './normalize'
hopsFormulas = require './app/hopsformulas'

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

		console.log trainingCases[100]
		console.log trainingCases[1000]
		trainingCases.splice 100, 1
		trainingCases.splice 1000, 1

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
