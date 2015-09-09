# beerbrain
The `beerbrain` project aims to classify beer recipy by style with the help of a
neural network using the aptly named [brain](https://github.com/harthur/brain)
Javascript library. The goal is to train a neural network to recognise the beer
style of a beer recipe simply by looking at the recipe's properties, such as
alcohol level, color, bitterness, ingredients, etc.

## Installation
`beerbrain` is a simple Coffee-Script project that runs on node. To get up and
running you simply need to clone the project:
```
git clone git@github.com:Microbrewit/beerbrain.git
cd beerbrain
```

Install coffee-script (if not already installed) and npm modules:
```
npm install coffee-script -g
npm install
```

Note! You will need at least Node.js version ~0.12 and CoffeeScript >= 1.9.
Node.js >=4.0.0 supports a lot of EcmaScript6 features out of the box. In such
a case you might not need to specify the `--harmony` option whe running the
beerbrain application.

## Configuration
```
cp config/config.coffee.example config/config.coffee
open config/config.coffee
```

The first object in the `config.coffee` file is related to the neural network
and the default values can be used. Feel free to experiment with the values
though as you might be able to squeeze out better results and/or performance.

The following object specifies properties to use for the
[Microbrew.it api](http://api.microbrew.it/) and currently includes only the
api URL.

```
exports.microbrewit =
  apiUrl: 'http://brewsite.example'
```

## Running
Running the application is super simple. It accepts one argument which is the
task to run, e.g. `coffee --nodejs --harmony index.coffee train|classify`. The
`--nodejs --harmony` options tells the coffee command to pass the `--harmony`
option to `node`. The `--harmony` option enables Node.js' EcmaScript6 features
such as Generators.

If you run Node.js >= 4.0.0 you are good to go and can likely omit the flags.

```
# Train the data
coffee --nodejs --harmony index.coffee train

# Classify the data
coffee --nodejs --harmony index.coffee classify
```
