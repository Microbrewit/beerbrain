brain = require './app/brain'

task = process.argv[2]

if task == 'train'
  brain.train()
else if task == 'classify'
  brain.classify()
else
  console.err 'Please call script with argument train or classify.'
