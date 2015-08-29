# Load neuralNetwork config
neuralNetworkConfig = (config = require './config').neuralNetwork
throw new Error 'Neural Network config missing' unless neuralNetworkConfig

# Import packages
brain = require 'brain'

# Create brain
beerBrain = new brain.NeuralNetwork()

# Train the brain
beerBrain.train [ {input: { r: 0.03, g: 0.7, b: 0.5 }, output: { black: 1 }},
                  {input: { r: 0.16, g: 0.09, b: 0.2 }, output: { white: 1 }},
                  {input: { r: 0.5, g: 0.5, b: 1.0 }, output: { white: 1 }}],
                  neuralNetworkConfig

# Classify some stuff
output = beerBrain.run { r: 1, g: 0.4, b: 0 }
output2 = beerBrain.run { r: 0.4, g: 1, b: 0.3 }

# Output results
console.log output
console.log output2
