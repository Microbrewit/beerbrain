# SRM values goes from 0 to 40
exports.normalizeSRM = (srm) ->
  srm / 40

# ABV goes from 0 to 100 in theory
exports.normalizeABV = (abv) ->
  abv / 100

# IBU should go from 0 to 120
exports.normalizeIBU = (ibu) ->
  ibu / 120

# Gravity goes from 1.000 (gravity of water) to a lot
exports.normalizeGravity = (og) ->
  (og - 1.000) / (1.300 - 1.000)
