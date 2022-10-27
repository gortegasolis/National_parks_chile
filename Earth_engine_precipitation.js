//Initialize main variables (datasets)
var precip = ee.Image("OpenLandMap/CLM/CLM_PRECIPITATION_SM2RAIN_M/v01"),
    parks = ee.FeatureCollection("projects/lte-maps-gortega/assets/snaspe");

// Visualize layers before anything else:
//Map.centerObject(parks);
//Map.addLayer(parks);

// Set the scale for our calculations to the raster scale (major accuracy possible)
var scale = precip.projection().nominalScale();

// Get the mean accessibility per protected area.
var pa_pp_mean = precip.reduceRegions({
  reducer: ee.Reducer.mean(),
  collection: parks,
  scale: scale
});

//Export results to Google Drive
Export.table.toDrive({
  collection: pa_pp_mean,
  description: "pa_pp_mean"});
