formulas = {}

formulas.available = () ->
	return ['rager', 'tinseth']

# Tinseth helpers
tinsethUtilisation = (og, boilTime) ->
	boilTimeFactor = (1-Math.exp(-0.04*boilTime))/4.15
	bignessFactor = 1.65*Math.pow(0.000125, (og-1))
	utilisation = bignessFactor * boilTimeFactor
	return utilisation

tinsethMgl = (weight, alphaAcid, batchSize) ->
	# mg/L
	alphaAcid = alphaAcid/100;

	return (alphaAcid*weight*1000)/batchSize

tinsethIbu = (mgl, utilisation) ->
	return utilisation*mgl

# Rager helpers
tanh = (x) ->
	e = Math.exp(2*x)
	return (e-1)/(e+1)

ragerUtilisation = (boilTime) ->
	return (18.11 + 13.86 * tanh((boilTime-31.32) / 18.27)) / 100

ragerIbu = (weight, utilisation, alphaAcid, boilVolume, boilGravity) ->
	ga = 0
	alphaAcid = alphaAcid/100
	if boilGravity > 1.050
		ga = (boilGravity-1.050)/0.2

	return (weight * utilisation * alphaAcid * 1000) / (boilVolume * (1+ga))

# hop mash adjustment
mashAdjustment = (aa) ->
	return aa*0.2 # 80% decrease in mash

# Rager
formulas.rager = (hopObj) ->
	hopObj.boilGravity = hopObj.boilGravity or 1.000
	utilisation = ragerUtilisation(hopObj.boilTime)
	mgl = tinsethMgl(hopObj.amount, hopObj.aa, hopObj.boilVolume)
	ibu = ragerIbu(hopObj.amount, utilisation, hopObj.aa, hopObj.boilVolume, hopObj.boilGravity)
	return {
		ibu: ibu
		utilisation: utilisation
		mgl: mgl
	}

# Tinseth
formulas.tinseth = (hopObj) ->
	hopObj.boilGravity ?= 1.000
	hopObj.boilTime ?= 60
	hopObj.boilVolume ?= 20
	mgl = tinsethMgl(hopObj.amount, hopObj.aaValue, hopObj.boilVolume)
	utilisation = tinsethUtilisation(hopObj.boilGravity, hopObj.boilTime)
	ibu = tinsethIbu(utilisation, mgl)
	return {
		ibu: ibu
		utilisation: utilisation
		mgl: mgl
	}

exports.formulas = formulas
