//Initialize main variables (datasets)
var parks = ee.FeatureCollection("projects/lte-maps-gortega/assets/snaspe"),
    access = ee.Image("Oxford/MAP/friction_surface_2019");

// Visualize layers before anything else:
//Map.centerObject(parks);
//Map.addLayer(parks);

// Set the scale for our calculations to the raster scale (major accuracy possible)
var scale = access.projection().nominalScale();

// Select the band with friction data
var acc_friction = access.select(["friction"]);

// Get the min accessibility per protected area.
var pa_acc_min = acc_friction.reduceRegions({
  reducer: ee.Reducer.min(),
  collection: parks,
  scale: scale
});

// Get the max accessibility per protected area.
var pa_acc_max = acc_friction.reduceRegions({
  reducer: ee.Reducer.max(),
  collection: parks,
  scale: scale
});

// Get the mean accessibility per protected area.
var pa_acc_mean = acc_friction.reduceRegions({
  reducer: ee.Reducer.mean(),
  collection: parks,
  scale: scale
});

//Export results to Google Drive
Export.table.toDrive({
  collection: pa_acc_min,
  description: "pa_acc_min"});

Export.table.toDrive({
  collection: pa_acc_max,
  description: "pa_acc_max"});

Export.table.toDrive({
  collection: pa_acc_mean,
  description: "pa_acc_mean"});
