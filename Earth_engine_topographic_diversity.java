//Initialize main variables (datasets)
var tdiv = ee.Image("CSP/ERGo/1_0/Global/ALOS_topoDiversity"),
    parks = ee.FeatureCollection("projects/lte-maps-gortega/assets/snaspe");

// Visualize layers before anything else:
//Map.centerObject(parks);
//Map.addLayer(parks);

// Set the scale for our calculations to the raster scale (major accuracy possible)
var scale = tdiv.projection().nominalScale();

// Select the band with topographic diversity data
var pa_tdiv = tdiv.select(["constant"]);

// Get the min topographic diversity per protected area.
var pa_tdiv_min = pa_tdiv.reduceRegions({
  reducer: ee.Reducer.min(),
  collection: parks,
  scale: scale
});

// Get the max topographic diversity per protected area.
var pa_tdiv_max = pa_tdiv.reduceRegions({
  reducer: ee.Reducer.max(),
  collection: parks,
  scale: scale
});

// Get the mean topographic diversity per protected area.
var pa_tdiv_mean = pa_tdiv.reduceRegions({
  reducer: ee.Reducer.mean(),
  collection: parks,
  scale: scale
});

//Export results to Google Drive
Export.table.toDrive({
  collection: pa_tdiv_min,
  description: "pa_tdiv_min"});
  
Export.table.toDrive({
  collection: pa_tdiv_max,
  description: "pa_tdiv_max"});
  
Export.table.toDrive({
  collection: pa_tdiv_mean,
  description: "pa_tdiv_mean"});
